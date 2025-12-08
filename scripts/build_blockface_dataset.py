import pandas as pd
import re
import numpy as np

base_path = r'C:\Users\ebkus\OneDrive\Documents\Math 261A - Gao\Project 2'

parking_meters = pd.read_csv(base_path + r'\Parking_Meters.csv')
citations = pd.read_csv(base_path + r'\SFMTA_Meter_Citations_2025.csv')

parking_meters = parking_meters[parking_meters['ACTIVE_METER_FLAG'].isin(['M', 'T'])]
pm_cols_to_keep = ['OBJECTID', 'MS_PAY_STATION_ID', 'MS_SPACE_NUM', 'ON_OFFSTREET_TYPE', 'BLOCKFACE_ID', 'METER_TYPE', 'CAP_COLOR',
       'STREET_ID', 'STREET_NAME', 'STREET_NUM', 'supervisor_district']
parking_meters = parking_meters[pm_cols_to_keep]
parking_meters['STREET_NUM'] = (
    parking_meters['STREET_NUM']
    .astype(str)
    .str.replace(',', '', regex=False)
)

citations_cols_to_keep = ['Citation Number', 'Violation',
       'Violation Description', 'Citation Location', 'Fine Amount']
citations = citations[citations_cols_to_keep]


parking_meters['STREET_NAME'] = (
    parking_meters['STREET_NAME']
    .astype(str)
    .str.upper()
    .str.strip()
)
parking_meters['STREET_NUM'] = pd.to_numeric(parking_meters['STREET_NUM'], errors='coerce')

pm_parity = parking_meters['STREET_NUM'].fillna(0).astype(int) % 2

parking_meters['parity'] = np.where(
    parking_meters['STREET_NUM'].notna(),
    pm_parity,
    np.nan
)

citations['Citation Location'] = (
    citations['Citation Location']
    .astype(str)
    .str.upper()
    .str.strip()
)

# Parse citation locations into street_num and street_name
def parse_location(loc):
    if not isinstance(loc, str) or loc.strip() == "":
        return pd.Series({'street_num': None, 'street_name': None})
    m = re.match(r"^\s*([0-9]+)\s+(.*\S)\s*$", loc)
    if m:
        return pd.Series({
            'street_num': int(m.group(1)),
            'street_name': m.group(2).strip()
        })
    else:
        return pd.Series({'street_num': None, 'street_name': None})

citations[['street_num', 'street_name']] = citations['Citation Location'].apply(parse_location)

ct_parity = citations['street_num'].fillna(0).astype(int) % 2

citations['parity'] = np.where(
    citations['street_num'].notna(),
    ct_parity,
    np.nan
)

def majority(x):
    m = x.mode()
    if len(m) > 0:
        return m.iloc[0]
    return np.nan

# Build blockface ranges for matching citations
bf_ranges = (
    parking_meters
    .groupby(['BLOCKFACE_ID', 'STREET_NAME'], as_index=False)
    .agg(
        min_street_num=('STREET_NUM', 'min'),
        max_street_num=('STREET_NUM', 'max'),
        block_parity=('parity', majority)   # 0 = even, 1 = odd
    )
)

# Match citations to blockfaces with same street_name + parity + street_num in range
tmp = citations.merge(
    bf_ranges,
    how='left',
    left_on='street_name',
    right_on='STREET_NAME'
)

mask = (
    tmp['street_num'].notna() &
    tmp['min_street_num'].notna() &
    tmp['block_parity'].notna() &
    tmp['parity'].notna() &
    (tmp['parity'] == tmp['block_parity']) &
    tmp['street_num'].between(tmp['min_street_num'], tmp['max_street_num'])
)

matches = tmp.loc[mask]

match_counts = matches.groupby('Citation Number').size()

one_match_ids = match_counts[match_counts == 1].index
matches_one = matches[matches['Citation Number'].isin(one_match_ids)]

# Aggregate unique citation counts per blockface
blockface_citations = (
    matches_one
    .groupby('BLOCKFACE_ID', as_index=False)['Citation Number']
    .nunique()
    .rename(columns={'Citation Number': 'citation_count'})
)

# core features per blockface
blockface_features = (
    parking_meters
    .groupby('BLOCKFACE_ID')
    .agg(
        street_name=('STREET_NAME', majority),
        supervisor_district=('supervisor_district', majority),
        meter_count=('OBJECTID', 'count'),
        min_street_num=('STREET_NUM', 'min'),
        max_street_num=('STREET_NUM', 'max'),
        on_offstreet_majority=('ON_OFFSTREET_TYPE', majority),
        cap_color_majority=('CAP_COLOR', majority),
        meter_type_majority=('METER_TYPE', majority)
    )
    .reset_index()
)

# on/off street proportions
onoff_props = (
    parking_meters
    .assign(is_on=lambda df: df['ON_OFFSTREET_TYPE'].eq('ON'))
    .groupby('BLOCKFACE_ID')
    .agg(on_street_prop=('is_on', 'mean'))
    .reset_index()
)
onoff_props['off_street_prop'] = 1 - onoff_props['on_street_prop']

blockface_features = blockface_features.merge(onoff_props, on='BLOCKFACE_ID', how='left')

# binary mostly-offstreet flag for interaction
blockface_features['is_offstreet'] = (blockface_features['off_street_prop'] > 0.5).astype(int)

# Combine features with citation counts and build response
blockfaces = blockface_features.merge(blockface_citations, on='BLOCKFACE_ID', how='left')
blockfaces['citation_count'] = blockfaces['citation_count'].fillna(0).astype(int)

blockfaces['citation_rate_per_meter'] = (
    blockfaces['citation_count'] / blockfaces['meter_count']
)

blockfaces['log_rate'] = np.log1p(blockfaces['citation_rate_per_meter'])


output_path = base_path + r'\blockface_regression_dataset_2025.csv'
blockfaces.to_csv(output_path, index=False)

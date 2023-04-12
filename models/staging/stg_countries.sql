select 
    row_number() over (order by country_code asc) as country_id
    , country_code
    , country_name
from {{ ref('countries') }}

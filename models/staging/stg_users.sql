with raw_data as (
    select
        user_identifier as user_id
        , min(received_at) as created_at
    from {{ ref('stg_page_views') }}
    group by 1
)

, generate_demographic_data as (
    select
        user_id
        , created_at
        , uniform(13, 100, random()) as age
        , uniform(0, 250, random()) as country_id
    from raw_data
)

, final as (
    select 
        generate_demographic_data.user_id
        , generate_demographic_data.created_at
        , generate_demographic_data.age
        , stg_countries.country_name
    from generate_demographic_data
    left join {{ ref('stg_countries') }}
        on generate_demographic_data.country_id = stg_countries.country_id
)

select * from final

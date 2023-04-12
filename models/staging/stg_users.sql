with raw_data as (
    select *
    from {{ ref('users') }}
)

, obscured as (
    select
        UUID_STRING() as user_id
        , dateadd('minute', uniform(0, 30, random()), created_at) as created_at
        , uniform(13, 100, random()) as age
        , uniform(0, 250, random()) as country_id
    from raw_data
)

, final as (
    select 
        obscured.user_id
        , obscured.created_at
        , obscured.age
        , stg_countries.country_name
    from obscured
    left join stg_countries
        on obscured.country_id = stg_countries.country_id
)

select * from final

with stg_users as (select * from {{ ref('stg_users') }})
, mapping_table as (select * from {{ ref('int_page_views_joined_to_user') }})

-- Join to the user-identifier mapping table to derive the user_identifier column from the pageview dataset
, final as (
    select
        stg_users.user_id
        , stg_users.created_at
        , stg_users.is_internal
        , stg_users.segment
        , mapping_table.user_identifier
    from stg_users
    left join mapping_table
        on stg_users.user_id = mapping_table.user_id
)

select * from final

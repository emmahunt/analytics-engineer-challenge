with stg_page_views as (select * from {{ ref('stg_page_views') }})
, mapping_table as (select * from {{ ref('int_page_views_joined_to_user') }})

-- Join to the user-identifier mapping table to derive the user_id: a foreign key to the user dimension in this table
, final as (
    select
        stg_page_views.page_path
        , stg_page_views.received_at

        -- This column could be excluded for true "normalisation" of the fact table
        -- In this case, as the table is not very wide I will leave it in
        , stg_page_views.user_identifier
        , mapping_table.user_id
    from stg_page_views
    left join mapping_table
        on stg_page_views.user_identifier = mapping_table.user_identifier
)

select * from final

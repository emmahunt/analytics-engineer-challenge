with stg_page_views as (select * from {{ ref('stg_page_views') }})

, final as (
    select distinct

        -- Use a natural key for the primary key here
        path as web_page_id
        , path
        , concat('https://www.synthesia.io', path) as url_raw

        -- These categorisations are demonstrative and would require working with the business / developers to refine
        , case
            when path = '/my_account' then 'account management'
            when path = '/template' then 'actors'
            when path = '/presentation' then 'project creation and management'
            when path = '/presentation' then 'project creation and management'
            when path = '/folder' then 'project creation and management'
            when path = '/themes' then 'project creation and management'
            when path = '/bin' then 'project creation and management'
            when path = '/folder' then 'project creation and management'
            when path = '/onboarding' then 'onboarding'
            when path = '/onboarding' then 'onboarding'
            when path = '/onboarding' then 'onboarding'
            when path = '/add_payment_details' then 'account management'
            when path = '/signup' then 'account management'
            when path = '/signup' then 'account management'
            when path = '/login' then 'account management'
            when path = '/survey' then 'account management'
            when path = '/subscription' then 'account management'
            when path = '/welcome' then 'account management'
            when path = '/password' then 'account management'
            else 'other'
        end as page_category
        
        -- This column captures the order in which steps are expected to be taken when a user signs up for the product
        -- Used for sorting the pages
        , case
            when path = '%pricing%' then 10
            when path = '%sign-up%' then 20
            when path = '%login%' then 20
            when path = '%missing-subs%' then 30
            when path = '%first-time-visit%' then 40
            when path = '%questionnaire%' then 50
        end as sign_up_process_ordinal
    from stg_page_views
)

select * from final

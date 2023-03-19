select * 
from {{ metrics.calculate(
    metric('active_users'),
    dimensions=['user_identifier'],
    grain='week'
) }}

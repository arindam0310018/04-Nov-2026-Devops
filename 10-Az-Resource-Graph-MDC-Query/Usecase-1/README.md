| AZURE RESOURCE GRAPH EXPLORER:- |
| :---------: |

| USE CASE #1:- |
| :---------: |
| Output only Specific Subscription Secure Score % |

__Note:-__
xxxxxxxxxxxxxxxxxxxxxxxxxxxxx = __Replace it with your own Subscription ID(s)__

```
SecurityResources
| where type =~ 'microsoft.security/securescores'
| where name =~ 'ascScore'
| where subscriptionId in~ (
    'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
    'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
)
| extend SecureScore = todouble(properties.score.percentage) * 100.0
| project subscriptionId, SecureScore
| join kind=leftouter (
    ResourceContainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionId, SubscriptionName = name
) on subscriptionId
| project
    ["Subscription Name"] = SubscriptionName,
    ["Secure Score (%)"] = round(SecureScore, 0)
| order by ["Subscription Name"] asc

```


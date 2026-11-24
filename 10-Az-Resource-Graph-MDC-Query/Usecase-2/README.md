| EXECUTE THE BELOW KQL IN AZURE RESOURCE GRAPH EXPLORER:- |
| :---------: |

| USE CASE #2:- |
| :---------: |
| Output ALL the Subscription Secure Score % to which the Identity has access to it. |

```
SecurityResources
| where type =~ 'microsoft.security/securescores'
| where name =~ 'ascScore'
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

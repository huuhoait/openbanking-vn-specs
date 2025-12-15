# Vận Hành & Yêu Cầu Phi Chức Năng (NFR)

> **Tuân thủ:** ISO/IEC 25010 (Quality Model) | ITIL v4 | ISO 22301 (Business Continuity)

## Tổng Quan

Tài liệu này định nghĩa các yêu cầu phi chức năng (Non-Functional Requirements) và quy trình vận hành để đảm bảo hệ thống Open Banking hoạt động ổn định, bảo mật, và đáp ứng SLA cam kết.

## SLA (Service Level Agreement)

### Availability Targets

| Service | Target Uptime | Max Downtime/Year | Max Downtime/Month |
|---------|---------------|-------------------|---------------------|
| **Core APIs** | 99.95% | 4.38 hours | 21.6 minutes |
| **Payment APIs** | 99.99% | 52.56 minutes | 4.32 minutes |
| **Developer Portal** | 99.9% | 8.76 hours | 43.2 minutes |
| **Monitoring** | 99.5% | 43.8 hours | 3.6 hours |

**Measurement:**
```
Uptime % = (Total Time - Downtime) / Total Time × 100

Planned Maintenance: Excluded (with 72h notice)
Force Majeure: Excluded
```

### Response Time Targets

```mermaid
graph LR
    subgraph "API Response Time SLA"
        Query[Query APIs<br/>GET /accounts<br/>---<br/>P95: < 200ms<br/>P99: < 500ms]
        
        Txn[Transaction APIs<br/>GET /transactions<br/>---<br/>P95: < 500ms<br/>P99: < 1s]
        
        Payment[Payment APIs<br/>POST /payments<br/>---<br/>P95: < 2s<br/>P99: < 5s]
        
        Batch[Batch APIs<br/>File upload<br/>---<br/>Async<br/>< 5 minutes]
    end
    
    style Query fill:#4caf50,color:#fff
    style Payment fill:#ff9800
```

**Performance Metrics:**
- **P50 (Median)**: 50% of requests faster than X
- **P95**: 95% of requests faster than X
- **P99**: 99% of requests faster than X
- **P99.9**: 99.9% of requests faster than X

### Throughput Capacity

```mermaid
graph TB
    subgraph "Capacity Planning"
        Peak[Peak Load<br/>---<br/>• 50,000 req/sec<br/>• 09:00-11:00<br/>• 14:00-16:00]
        
        Normal[Normal Load<br/>---<br/>• 10,000 req/sec<br/>• Business hours<br/>• 80% baseline]
        
        Low[Low Load<br/>---<br/>• 2,000 req/sec<br/>• Night hours<br/>• 20% baseline]
    end
    
    subgraph "Auto-scaling"
        Scale[Auto-scale Rules<br/>---<br/>• CPU > 70%: +2 pods<br/>• Memory > 80%: +2 pods<br/>• Queue depth > 1000: +3 pods<br/>• Scale down after 10 min]
    end
    
    Peak --> Scale
    Normal --> Scale
    Low --> Scale
    
    style Peak fill:#f44336,color:#fff
    style Scale fill:#4caf50,color:#fff
```

## Architecture for High Availability

### Multi-Region Deployment

```mermaid
graph TB
    subgraph "Global Load Balancer"
        GLB[AWS Route53<br/>GeoDNS + Health Check]
    end
    
    subgraph "Region 1 - Ho Chi Minh"
        LB1[Load Balancer<br/>ALB]
        AZ1A[AZ-1a<br/>API Pods × 3]
        AZ1B[AZ-1b<br/>API Pods × 3]
        DB1[Aurora Primary<br/>Multi-AZ]
        Cache1[Redis Cluster<br/>3 nodes]
    end
    
    subgraph "Region 2 - Ha Noi"
        LB2[Load Balancer<br/>ALB]
        AZ2A[AZ-2a<br/>API Pods × 3]
        AZ2B[AZ-2b<br/>API Pods × 3]
        DB2[Aurora Read Replica<br/>Multi-AZ]
        Cache2[Redis Cluster<br/>3 nodes]
    end
    
    GLB -->|Primary| LB1
    GLB -->|Failover| LB2
    
    LB1 --> AZ1A
    LB1 --> AZ1B
    
    LB2 --> AZ2A
    LB2 --> AZ2B
    
    AZ1A --> DB1
    AZ1B --> DB1
    AZ1A --> Cache1
    AZ1B --> Cache1
    
    AZ2A --> DB2
    AZ2B --> DB2
    AZ2A --> Cache2
    AZ2B --> Cache2
    
    DB1 -.->|Replication| DB2
    
    style GLB fill:#4caf50,color:#fff
    style DB1 fill:#2196f3,color:#fff
    style DB2 fill:#2196f3,color:#fff
```

### Database Architecture

```mermaid
graph TB
    subgraph "Write Path"
        App_W[Application<br/>Write Operations]
        Primary[Aurora Primary<br/>Writer Instance]
    end
    
    subgraph "Read Path"
        App_R[Application<br/>Read Operations]
        Reader_LB[Reader Endpoint<br/>Load Balancer]
        Replica1[Read Replica 1<br/>AZ-1a]
        Replica2[Read Replica 2<br/>AZ-1b]
        Replica3[Read Replica 3<br/>Cross-region]
    end
    
    subgraph "Backup"
        Snapshot[Automated Snapshots<br/>Daily + Continuous]
        S3[S3 Backup<br/>7-year retention]
    end
    
    App_W --> Primary
    Primary -->|Replication| Replica1
    Primary -->|Replication| Replica2
    Primary -->|Replication| Replica3
    
    App_R --> Reader_LB
    Reader_LB --> Replica1
    Reader_LB --> Replica2
    Reader_LB --> Replica3
    
    Primary --> Snapshot
    Snapshot --> S3
    
    style Primary fill:#4caf50,color:#fff
    style Reader_LB fill:#2196f3,color:#fff
```

## Disaster Recovery

### RPO & RTO Targets

```mermaid
graph LR
    subgraph "Recovery Objectives"
        RPO[RPO<br/>Recovery Point Objective<br/>---<br/>Max data loss: 1 hour<br/>Continuous replication]
        
        RTO[RTO<br/>Recovery Time Objective<br/>---<br/>Max downtime: 4 hours<br/>Auto-failover: 5 min]
    end
    
    subgraph "Backup Strategy"
        Continuous[Continuous Backup<br/>---<br/>• Transaction logs<br/>• Point-in-time recovery<br/>• 35-day retention]
        
        Daily[Daily Snapshots<br/>---<br/>• Full database<br/>• Encrypted<br/>• Multi-region copy]
        
        Weekly[Weekly Archive<br/>---<br/>• Long-term storage<br/>• S3 Glacier<br/>• 7-year retention]
    end
    
    RPO --> Continuous
    RTO --> Continuous
    Continuous --> Daily
    Daily --> Weekly
    
    style RPO fill:#f44336,color:#fff
    style RTO fill:#ff9800
```

### DR Procedures

```mermaid
sequenceDiagram
    participant Mon as Monitoring
    participant Ops as Operations Team
    participant LB as Load Balancer
    participant Primary as Primary Region
    participant DR as DR Region
    participant Comm as Communications
    
    Note over Mon: Detect Outage
    Mon->>Mon: Health check failed × 3
    Mon->>Ops: Alert: Primary down 🚨
    
    Ops->>Ops: Verify: True outage
    Ops->>Comm: Notify stakeholders
    
    Ops->>LB: Initiate Failover
    LB->>LB: Update DNS<br/>TTL: 60s
    LB->>DR: Route traffic to DR
    
    DR->>DR: Verify services up
    DR->>DR: Promote read replica<br/>to primary
    
    DR-->>LB: Ready
    LB-->>Ops: Failover complete
    
    Ops->>Comm: Status: Running on DR
    
    Note over Ops: Monitor DR performance
    
    alt Primary Recovered
        Ops->>Primary: Restore services
        Primary->>Primary: Sync data from DR
        Ops->>LB: Failback to primary
        LB->>Primary: Route traffic back
        Ops->>Comm: Resolved: Back to primary
    end
```

## Monitoring & Observability

### Monitoring Architecture

```mermaid
graph TB
    subgraph "Data Collection"
        App[Applications<br/>OpenTelemetry]
        Infra[Infrastructure<br/>Node Exporter]
        DB[Databases<br/>CloudWatch]
        LB[Load Balancers<br/>Access Logs]
    end
    
    subgraph "Aggregation"
        Prometheus[Prometheus<br/>Metrics Storage]
        Loki[Loki<br/>Log Aggregation]
        Tempo[Tempo<br/>Distributed Tracing]
    end
    
    subgraph "Visualization"
        Grafana[Grafana<br/>Dashboards]
        Alert[AlertManager<br/>Notifications]
    end
    
    subgraph "Notifications"
        PagerDuty[PagerDuty<br/>On-call]
        Slack[Slack<br/>Team channel]
        Email[Email<br/>Management]
    end
    
    App --> Prometheus
    App --> Loki
    App --> Tempo
    Infra --> Prometheus
    DB --> Prometheus
    LB --> Loki
    
    Prometheus --> Grafana
    Loki --> Grafana
    Tempo --> Grafana
    
    Prometheus --> Alert
    Alert --> PagerDuty
    Alert --> Slack
    Alert --> Email
    
    style Alert fill:#f44336,color:#fff
    style Grafana fill:#ff9800
```

### Key Metrics (Golden Signals)

```mermaid
graph TB
    subgraph "Golden Signals"
        Latency[Latency<br/>---<br/>• Response time<br/>• P50, P95, P99<br/>• By endpoint]
        
        Traffic[Traffic<br/>---<br/>• Requests/sec<br/>• By TPP<br/>• By API type]
        
        Errors[Errors<br/>---<br/>• Error rate %<br/>• 4xx, 5xx<br/>• By status code]
        
        Saturation[Saturation<br/>---<br/>• CPU usage<br/>• Memory usage<br/>• Queue depth]
    end
    
    subgraph "Business Metrics"
        TPP_Active[Active TPPs<br/>Daily/Monthly]
        Revenue[Revenue<br/>Real-time]
        Conversion[Conversion Rate<br/>Sandbox → Prod]
    end
    
    style Errors fill:#f44336,color:#fff
    style Revenue fill:#4caf50,color:#fff
```

### Alerting Rules

```mermaid
graph TB
    subgraph "Critical Alerts (P1)"
        Down[Service Down<br/>---<br/>• Health check failed<br/>• Page on-call<br/>• RTO: 15 min]
        
        Error[High Error Rate<br/>---<br/>• >5% errors<br/>• Page on-call<br/>• RTO: 30 min]
        
        Payment[Payment Failures<br/>---<br/>• >1% failed<br/>• Page on-call<br/>• RTO: 15 min]
    end
    
    subgraph "Warning Alerts (P2)"
        Slow[Slow Response<br/>---<br/>• P95 > SLA + 50%<br/>• Slack notify<br/>• RTO: 2 hours]
        
        Capacity[High Load<br/>---<br/>• CPU > 80%<br/>• Slack notify<br/>• RTO: 4 hours]
    end
    
    subgraph "Info Alerts (P3)"
        Quota[Quota Warning<br/>---<br/>• 80% used<br/>• Email<br/>• RTO: 24 hours]
    end
    
    Down --> PagerDuty[PagerDuty]
    Error --> PagerDuty
    Payment --> PagerDuty
    
    Slow --> Slack[Slack]
    Capacity --> Slack
    
    Quota --> Email[Email]
    
    style Down fill:#f44336,color:#fff
    style Payment fill:#f44336,color:#fff
```

## Security Operations

### Security Monitoring

```mermaid
graph TB
    subgraph "Threat Detection"
        WAF[AWS WAF<br/>---<br/>• SQL injection<br/>• XSS attacks<br/>• Rate limit abuse]
        
        IDS[Intrusion Detection<br/>---<br/>• Unusual patterns<br/>• Brute force<br/>• Data exfiltration]
        
        Audit[Audit Logs<br/>---<br/>• All API calls<br/>• Admin actions<br/>• Data access]
    end
    
    subgraph "SIEM"
        Splunk[Splunk<br/>Security Analytics]
    end
    
    subgraph "Response"
        SOC[SOC Team<br/>24/7]
        Block[Auto-block<br/>Suspicious IPs]
        Incident[Incident Response<br/>Playbook]
    end
    
    WAF --> Splunk
    IDS --> Splunk
    Audit --> Splunk
    
    Splunk --> SOC
    SOC --> Block
    SOC --> Incident
    
    style WAF fill:#f44336,color:#fff
    style SOC fill:#ff9800
```

### Incident Response

```mermaid
graph TB
    Detection[Incident Detected]
    
    Detection --> Classify{Severity}
    
    Classify -->|P1 Critical| P1[P1: System Down<br/>---<br/>• Page on-call<br/>• War room<br/>• Exec notification]
    
    Classify -->|P2 High| P2[P2: Degraded Service<br/>---<br/>• Alert team<br/>• Incident channel<br/>• Manager notification]
    
    Classify -->|P3 Medium| P3[P3: Minor Issue<br/>---<br/>• Create ticket<br/>• Normal workflow<br/>• No notification]
    
    P1 --> Respond[Incident Response]
    P2 --> Respond
    P3 --> Respond
    
    Respond --> Resolve[Resolve Issue]
    Resolve --> RCA[Root Cause Analysis]
    RCA --> Improve[Implement Improvements]
    
    style P1 fill:#f44336,color:#fff
    style Respond fill:#ff9800
```

## Capacity Planning

### Growth Projection

```mermaid
graph LR
    subgraph "Current (Year 1)"
        TPP1[TPPs: 50<br/>API Calls: 100M/month<br/>Peak: 5K req/sec]
    end
    
    subgraph "Year 2"
        TPP2[TPPs: 200<br/>API Calls: 500M/month<br/>Peak: 25K req/sec]
    end
    
    subgraph "Year 3"
        TPP3[TPPs: 500<br/>API Calls: 2B/month<br/>Peak: 100K req/sec]
    end
    
    TPP1 -->|4x growth| TPP2
    TPP2 -->|4x growth| TPP3
    
    style TPP3 fill:#4caf50,color:#fff
```

### Infrastructure Scaling

| Component | Current | Year 2 | Year 3 |
|-----------|---------|--------|--------|
| **API Pods** | 20 | 80 | 320 |
| **Database** | 1 × db.r6g.2xlarge | 2 × db.r6g.8xlarge | 4 × db.r6g.16xlarge |
| **Redis** | 3-node (8GB) | 6-node (32GB) | 12-node (128GB) |
| **Storage** | 500GB | 5TB | 50TB |
| **Monthly Cost** | $10,000 | $50,000 | $250,000 |

## Performance Optimization

### Caching Strategy

```mermaid
graph TB
    Request[API Request]
    
    Request --> L1{L1 Cache<br/>Redis<br/>TTL: 60s}
    
    L1 -->|Hit| Return1[Return Cached]
    L1 -->|Miss| L2{L2 Cache<br/>Application<br/>TTL: 300s}
    
    L2 -->|Hit| Return2[Return Cached]
    L2 -->|Miss| DB[Query Database]
    
    DB --> Cache[Update Caches]
    Cache --> Return3[Return Fresh Data]
    
    style L1 fill:#4caf50,color:#fff
    style Return1 fill:#4caf50,color:#fff
```

**Cache Hit Ratio Target:** >95%

### Database Optimization

```mermaid
graph TB
    subgraph "Query Optimization"
        Index[Indexing Strategy<br/>---<br/>• Primary keys<br/>• Foreign keys<br/>• Query patterns]
        
        Partition[Table Partitioning<br/>---<br/>• By date (monthly)<br/>• By TPP ID<br/>• Archive old data]
        
        Pool[Connection Pooling<br/>---<br/>• Min: 10<br/>• Max: 100<br/>• Timeout: 30s]
    end
    
    subgraph "Read/Write Split"
        Write[Write Operations<br/>→ Primary]
        Read[Read Operations<br/>→ Read Replicas]
    end
    
    Index --> Performance[Query Performance<br/>< 100ms]
    Partition --> Performance
    Pool --> Performance
    
    style Performance fill:#4caf50,color:#fff
```

## Change Management

### Deployment Pipeline

```mermaid
graph LR
    Dev[Development<br/>Local env]
    
    Dev --> PR[Pull Request<br/>Code review]
    PR --> CI{CI Pipeline}
    
    CI -->|Pass| Build[Build Image<br/>Docker]
    CI -->|Fail| Reject[❌ Reject]
    
    Build --> Test[Automated Tests<br/>Unit + Integration]
    
    Test -->|Pass| Staging[Deploy Staging<br/>Canary 10%]
    Test -->|Fail| Reject2[❌ Rollback]
    
    Staging --> Approve{Manual Approval<br/>QA Sign-off}
    
    Approve -->|✓| Prod[Deploy Production<br/>Blue-Green]
    Approve -->|✗| Reject3[❌ Cancel]
    
    Prod --> Monitor[Monitor 1 hour]
    Monitor -->|Success| Done[✓ Complete]
    Monitor -->|Issues| Rollback[↩ Auto-rollback]
    
    style Prod fill:#4caf50,color:#fff
    style Rollback fill:#f44336,color:#fff
```

### Deployment Schedule

**Production Deployments:**
- **Preferred Window**: Tuesday & Thursday, 10:00-12:00
- **Freeze Period**: Friday, Holidays, Month-end
- **Change Advisory Board**: Weekly review
- **Emergency Hotfix**: Anytime with approval

## Compliance & Audit

### Audit Requirements

```mermaid
graph TB
    subgraph "Audit Trail"
        API[API Access Logs<br/>---<br/>• Who<br/>• What<br/>• When<br/>• Result]
        
        Admin[Admin Actions<br/>---<br/>• Configuration changes<br/>• User management<br/>• Permission changes]
        
        Data[Data Access<br/>---<br/>• PII access<br/>• Data export<br/>• Consent usage]
    end
    
    subgraph "Retention"
        Hot[Hot Storage<br/>90 days<br/>Fast access]
        
        Warm[Warm Storage<br/>1 year<br/>S3]
        
        Cold[Cold Storage<br/>7 years<br/>Glacier]
    end
    
    API --> Hot
    Admin --> Hot
    Data --> Hot
    
    Hot --> Warm
    Warm --> Cold
    
    style Cold fill:#2196f3,color:#fff
```

### Compliance Checklist

**Regular Audits:**
- ✅ **ISO 27001** - Annual certification
- ✅ **PCI DSS 4.0** - Quarterly scan
- ✅ **SOC 2 Type II** - Annual audit
- ✅ **Penetration Testing** - Quarterly
- ✅ **Vulnerability Scanning** - Weekly
- ✅ **Access Review** - Monthly
- ✅ **Backup Testing** - Monthly
- ✅ **DR Drill** - Quarterly

## Cost Management

### Cost Optimization

```mermaid
graph TB
    subgraph "Compute"
        Spot[Spot Instances<br/>---<br/>• Non-prod: 90% savings<br/>• Batch jobs<br/>• Auto-fallback]
        
        Reserved[Reserved Instances<br/>---<br/>• Prod: 40% savings<br/>• 1-year commit<br/>• Steady workload]
        
        Serverless[Serverless<br/>---<br/>• Lambda for tasks<br/>• Pay per use<br/>• Auto-scale]
    end
    
    subgraph "Storage"
        Lifecycle[S3 Lifecycle<br/>---<br/>• Hot → Warm: 30 days<br/>• Warm → Cold: 90 days<br/>• Delete: 7 years]
        
        Compression[Compression<br/>---<br/>• Logs: gzip<br/>• Backups: encrypted<br/>• 70% reduction]
    end
    
    subgraph "Monitoring"
        Budget[Budget Alerts<br/>---<br/>• 80%: Warning<br/>• 100%: Critical<br/>• Auto-report]
    end
    
    style Spot fill:#4caf50,color:#fff
    style Budget fill:#ff9800
```

### Cost Breakdown (Monthly)

```mermaid
pie title Infrastructure Cost Distribution
    "Compute (EC2/EKS)" : 40
    "Database (Aurora)" : 25
    "Networking (ALB/NAT)" : 15
    "Storage (S3/EBS)" : 10
    "Monitoring (CloudWatch)" : 5
    "Other (Backups/DNS)" : 5
```

## Tài Liệu Tham Khảo

- **ISO/IEC 25010:2011** - Systems and Software Quality Models
- **ITIL v4** - IT Service Management
- **ISO 22301:2019** - Business Continuity Management
- **AWS Well-Architected Framework** - Best Practices
- **Google SRE Book** - Site Reliability Engineering

---

**Phiên bản:** 1.0  
**Ngày cập nhật:** 15/12/2025  
**Trạng thái:** Production Ready

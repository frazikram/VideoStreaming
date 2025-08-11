# 🎬 Netflix-Style Streaming Platform – Design Document

## 1. Overview

A backend-first, distributed video streaming platform delivering secure, adaptive bitrate video to web, mobile, and TV clients. Designed for scalability, DRM protection, and operational excellence.

---

## 2. Tech Stack Summary

| Layer                | Technology                                           |
|----------------------|-------------------------------------------------------|
| **Backend**          | Go (chi/echo, net/http, gRPC, protobuf)               |
| **Video Processing** | FFmpeg (x264/x265)                                    |
| **Infrastructure**   | AWS (S3, CloudFront, Aurora, ElastiCache, MSK, SQS, EventBridge, KMS) |
| **SQL**              | Amazon Aurora (PostgreSQL)                            |
| **NoSQL/Search**     | Redis (ElastiCache), OpenSearch                       |
| **Messaging**        | Kafka (MSK), SQS, EventBridge                         |
| **IaC**              | Terraform                                             |
| **CI/CD**            | GitHub Actions + OIDC to AWS                          |
| **Clients**          | React (Web), React Native (Mobile/TV)                 |

---

## 3. High-Level Architecture

```
+---------------------------+
|       Client Apps         |
|---------------------------|
| - Web (React)             |
| - Mobile (React Native)   |
| - TV (React Native)       |
+-------------+-------------+
              |
+-------------v-------------+
|    API Gateway / Envoy    |
+-------------+-------------+
              |
      +-------v--------+
      |   Go Services   |
      +-----------------+
      | Ingestion        |
      | Transcode Orches |
      | Packager/DRM     |
      | Playback API     |
      | License Service  |
      | Catalog          |
      | User/Profile     |
      | Recommendations  |
      | Telemetry        |
      +-----------------+
              |
+------+------+------+------+--------------+
| S3   | Aurora | Redis | OpenSearch | MSK |
|      |        |       |            |     |
+------+------+------+------+--------------+
```

---

## 4. Backend Services (Go Microservices)

| Service             | Description                                              | Storage           |
|---------------------|----------------------------------------------------------|-------------------|
| Ingestion           | Handles uploads, pre-signed URLs, metadata extraction    | S3                |
| Transcode Orchestr. | Manages transcoding jobs via SQS/EventBridge              | S3                |
| Transcoder Workers  | FFmpeg workers producing ABR renditions                  | S3                |
| Packager/DRM        | CMAF packaging, encryption, DRM key management           | S3 + KMS           |
| Playback API        | Issues signed manifests, play tokens                     | Redis + Aurora    |
| License Service     | Issues Widevine/FairPlay/PlayReady licenses               | Aurora + KMS      |
| Catalog             | Stores titles, metadata, availability                    | Aurora + OpenSearch|
| User/Profile        | User accounts, profiles, parental controls               | Aurora            |
| Recommendations     | Heuristic + batch recsys                                 | Redis             |
| Telemetry           | QoE metrics, playback events via Kafka                    | S3 (analytics)    |

---

## 5. Data Modeling

| Entity          | Store           | Reason                                         |
|-----------------|-----------------|------------------------------------------------|
| Titles          | Aurora          | Relational metadata, rights windows            |
| Profiles        | Aurora          | Linked to users, parental controls             |
| Assets          | S3              | Master, mezzanine, packaged segments           |
| Renditions      | S3              | ABR ladder segments                            |
| DRM Keys        | KMS/HSM + Aurora| Secure storage and rotation of encryption keys |
| Playback State  | Redis           | Fast access to session state                   |
| Watch History   | Aurora          | Resume and continue watching                   |
| Telemetry       | Kafka/S3        | Playback analytics and QoE measurements       |

---

## 6. Infrastructure (AWS + Terraform)

### 🔧 Terraform Modules

| Module         | Purpose                                      |
|----------------|----------------------------------------------|
| `vpc/`         | Networking setup                             |
| `aurora/`      | PostgreSQL cluster                           |
| `redis/`       | ElastiCache Redis                            |
| `msk/`         | Kafka for telemetry                          |
| `s3/`          | Raw, mezzanine, packaged, manifest storage   |
| `cloudfront/`  | CDN distribution with origin shield          |
| `sqs/`         | Transcoding job queues                       |
| `iam/`         | Service permissions                          |
| `kms/`         | DRM key management                           |

---

## 7. CI/CD Plan

| Component | Tool                       | Purpose                        |
|-----------|----------------------------|---------------------------------|
| Backend   | GitHub Actions + ECS/EKS   | Go services build & deploy      |
| Infra     | Terraform Cloud / CLI      | Infrastructure automation       |
| Clients   | Vercel / EAS                | Web and mobile deployments      |

---

## 8. Security Considerations

- Cognito OIDC + JWT for auth
- Signed URLs for manifest and segment delivery
- mTLS between internal services
- DRM keys stored only in KMS/HSM
- VPC isolation for sensitive workloads
- Secrets in AWS Secrets Manager
- Rate limiting at API Gateway

---

## 9. Future Enhancements

- Per-title bitrate ladder optimization
- HEVC/4K + HDR streaming
- Offline downloads with persistent licenses
- Advanced personalization and ML-based recommendations
- Live streaming support

---

## 10. Monorepo Layout

```
/streaming-platform
│
├── /clients
│   ├── /web         # React app
│   └── /mobile      # React Native app
│
├── /backend         # Go microservices
│   ├── /services    # Ingestion, Playback, License, etc.
│   └── /pkg         # Shared libraries
│
├── /infra           # Terraform IaC
│   ├── /modules     # Reusable TF modules
│   └── /environments/dev, staging, prod
│
└── README.md
```

# Haraka Rides - Data Warehousing & Vehicle Profitability Report

**Database Management System:** PostgreSQL  
**Data Ingestion Method:** pgAdmin Import/Export Wizard Tool  
**Data Scope:** 406 Raw Trips, 106 Raw Fleet Events  
**Developer/Group:** Faith N. & Team

## Project Overview
This project involves building a centralized, clean data ecosystem for Haraka Rides, a Nairobi ride-hailing startup. Raw, messy booking exports (\	rips_staging\) and fleet logs (\leet_staging\) were ingested into wide-open text staging schemas using the pgAdmin Import/Export Wizard to ensure raw structure containment. The data was subsequently profiled for irregularities and systematically migrated into structured production tables using absolute, alias-free SQL logic.

## Production Schema Design
We established a strict relational architecture separated into domain schemas:
* **fleet.vehicles**: The canonical master asset index (12 unique vehicles).
* **fleet.fuel_logs & fleet.maintenance_logs**: Split expense trackers utilizing raw system log_id keys.
* **booking.customers & booking.drivers**: Normalized actor tables extracted and deduplicated from text streams.
* **booking.trips**: Transactional table integrating foreign key boundaries across schemas.

## Data Ingestion & Profiling Insights (Phase 1 & 2)
1. **Ingestion via Wizard:** Staging tables were explicitly defined with all columns configured as TEXT. The pgAdmin Import Wizard successfully processed the header rows without row dropping.
2. **Date Formats:** Identified 4 conflicting patterns (ISO, US dash, UK slash, 2-digit years) solved with clean conditional logic mapping.
3. **Monetary Formats:** Stripped currency tokens (e.g., KES, commas) via regular expressions (REGEXP_REPLACE).
4. **Data Quality Errors:** Caught and converted string "NULL" anomalies to structural DB nulls, and resolved raw duplication on fuel entry ID 4.

## Capstone Financial Recommendations
Our cross-schema vehicle profitability analysis revealed that the **Toyota Probox (KDB869I)** is the least profitable asset in the entire fleet, generating **0.00 revenue** while accumulating a staggering net loss of **-KES 128,452.00** purely from overhead repair locks.

**Management Action Items:**
* **Immediate Asset Retirement:** Halt all further maintenance allocations to the Toyota Probox (KDB869I) and initiate liquidation protocols, as its mechanical grounding completely voids profitability.
* **Targeted Mechanical Audit:** Trigger an immediate operational audit on the **Toyota Axio (KDA496F)**, which ranks as the second-highest maintenance drag (-KES 108,446.00) despite actively running trips.

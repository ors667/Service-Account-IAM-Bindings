##############################################################################
# iam_bindings.tf
# Meridian Health — Service Account Infrastructure
#
# Assigns IAM roles to service accounts using resource-level bindings.
# The canonical GCP pattern is to attach each binding directly to the
# specific resource it needs to access — bucket, instance, topic, secret —
# rather than granting at project level and narrowing with conditions.
#
# IAM Conditions are not used here as a scoping mechanism. Scoping is
# achieved by using the appropriate resource-level IAM resource type.
#
# Policy references:
#   - IAM Role Assignment Policy (Confluence)
#   - PHI Data Access Policy — Service Accounts (Confluence)
##############################################################################

##############################################################################
# OBSERVABILITY — All service accounts
# roles/logging.logWriter, roles/monitoring.metricWriter, roles/cloudtrace.agent
# are granted at project level — correct for these roles as they write to
# project-level sinks and do not access data resources.
##############################################################################

resource "google_project_iam_member" "logging" {
  for_each = local.applications

  project = each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${each.key}-${each.value.env}-svc@${each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id}.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "monitoring" {
  for_each = local.applications

  project = each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${each.key}-${each.value.env}-svc@${each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id}.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "tracing" {
  for_each = local.applications

  project = each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${each.key}-${each.value.env}-svc@${each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id}.iam.gserviceaccount.com"
}

##############################################################################
# PHI APPLICATIONS — Cloud SQL access
# Canonical pattern: google_sql_database_instance_iam_member scoped directly
# to the specific instance. No condition required.
##############################################################################

resource "google_sql_database_instance_iam_member" "ehr_core_cloudsql" {
  project  = var.prod_project_id
  instance = var.phi_cloudsql_instances["ehr_primary"]
  role     = "roles/cloudsql.client"
  member   = "serviceAccount:ehr-core-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_sql_database_instance_iam_member" "clinical_notes_cloudsql" {
  project  = var.prod_project_id
  instance = var.phi_cloudsql_instances["clinical_notes"]
  role     = "roles/cloudsql.client"
  member   = "serviceAccount:clinical-notes-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_sql_database_instance_iam_member" "lab_systems_cloudsql" {
  project  = var.prod_project_id
  instance = var.phi_cloudsql_instances["lab_systems"]
  role     = "roles/cloudsql.client"
  member   = "serviceAccount:lab-systems-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_sql_database_instance_iam_member" "pharmacy_mgmt_cloudsql" {
  project  = var.prod_project_id
  instance = var.phi_cloudsql_instances["pharmacy"]
  role     = "roles/cloudsql.client"
  member   = "serviceAccount:pharmacy-mgmt-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_sql_database_instance_iam_member" "care_coordination_cloudsql" {
  project  = var.prod_project_id
  instance = var.phi_cloudsql_instances["care_coordination"]
  role     = "roles/cloudsql.client"
  member   = "serviceAccount:care-coordination-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_sql_database_instance_iam_member" "medication_admin_cloudsql" {
  project  = var.prod_project_id
  instance = var.phi_cloudsql_instances["medication_admin"]
  role     = "roles/cloudsql.client"
  member   = "serviceAccount:medication-admin-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_sql_database_instance_iam_member" "radiology_cloudsql" {
  project  = var.prod_project_id
  instance = var.phi_cloudsql_instances["radiology"]
  role     = "roles/cloudsql.client"
  member   = "serviceAccount:radiology-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

##############################################################################
# PHI APPLICATIONS — GCS bucket access
# Canonical pattern: google_storage_bucket_iam_member scoped to the specific
# bucket. The binding is already resource-level — no condition required.
##############################################################################

resource "google_storage_bucket_iam_member" "ehr_core_gcs_reader" {
  bucket = var.phi_gcs_buckets["ehr_primary"]
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:ehr-core-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "clinical_notes_gcs_writer" {
  bucket = var.phi_gcs_buckets["clinical_docs"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:clinical-notes-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "clinical_imaging_gcs_writer" {
  bucket = var.phi_gcs_buckets["imaging_dicom"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:clinical-imaging-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "lab_systems_gcs_writer" {
  bucket = var.phi_gcs_buckets["lab_results"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:lab-systems-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "pharmacy_gcs_writer" {
  bucket = var.phi_gcs_buckets["pharmacy_records"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:pharmacy-mgmt-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

##############################################################################
# PHI APPLICATIONS — BigQuery access
# Dataset-level binding. bigquery.jobUser is granted at project level —
# required and correct as job execution is a project-level operation.
##############################################################################

resource "google_bigquery_dataset_iam_member" "ehr_core_bq_viewer" {
  project    = var.prod_project_id
  dataset_id = var.phi_bigquery_datasets["ehr_analytics"]
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:ehr-core-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_project_iam_member" "ehr_core_bq_job_user" {
  project = var.prod_project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:ehr-core-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_bigquery_dataset_iam_member" "analytics_platform_bq_viewer" {
  project    = var.prod_project_id
  dataset_id = var.phi_bigquery_datasets["clinical"]
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:analytics-platform-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_project_iam_member" "analytics_platform_bq_job_user" {
  project = var.prod_project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:analytics-platform-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_bigquery_dataset_iam_member" "reporting_svc_bq_viewer" {
  project    = var.prod_project_id
  dataset_id = var.phi_bigquery_datasets["clinical"]
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:reporting-svc-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_project_iam_member" "reporting_svc_bq_job_user" {
  project = var.prod_project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:reporting-svc-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

##############################################################################
# PHI APPLICATIONS — Pub/Sub
# Canonical pattern: google_pubsub_topic_iam_member scoped to the specific
# topic. The binding is already resource-level — no condition required.
##############################################################################

resource "google_pubsub_topic_iam_member" "referral_mgmt_fhir_publisher" {
  project = var.prod_project_id
  topic   = var.phi_pubsub_topics["fhir_events"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:referral-mgmt-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_topic_iam_member" "device_integration_telemetry_publisher" {
  project = var.prod_project_id
  topic   = var.phi_pubsub_topics["device_telemetry"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:device-integration-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_topic_iam_member" "ehr_core_adt_publisher" {
  project = var.prod_project_id
  topic   = var.phi_pubsub_topics["adt_events"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:ehr-core-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

##############################################################################
# NON-PHI APPLICATIONS — GCS access (bucket-level)
##############################################################################

resource "google_storage_bucket_iam_member" "analytics_platform_gcs_reader" {
  bucket = var.internal_gcs_buckets["analytics_staging"]
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:analytics-platform-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "reporting_svc_gcs_writer" {
  bucket = var.internal_gcs_buckets["reporting_output"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:reporting-svc-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "data_integration_gcs_writer" {
  bucket = var.internal_gcs_buckets["etl_staging"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:data-integration-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "document_mgmt_gcs_writer" {
  bucket = var.internal_gcs_buckets["document_store"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:document-mgmt-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "audit_logging_gcs_writer" {
  bucket = var.internal_gcs_buckets["audit_logs"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:audit-logging-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

##############################################################################
# NON-PHI APPLICATIONS — Pub/Sub (topic/subscription-level)
##############################################################################

resource "google_pubsub_topic_iam_member" "notification_svc_publisher" {
  project = var.prod_project_id
  topic   = var.internal_pubsub_topics["notification_alerts"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:notification-svc-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_subscription_iam_member" "notification_svc_subscriber" {
  project      = var.prod_project_id
  subscription = var.internal_pubsub_subscriptions["notification_sub"]
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:notification-svc-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_topic_iam_member" "billing_platform_publisher" {
  project = var.prod_project_id
  topic   = var.internal_pubsub_topics["billing_events"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:billing-platform-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_topic_iam_member" "supply_chain_publisher" {
  project = var.prod_project_id
  topic   = var.internal_pubsub_topics["supply_events"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:supply-chain-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_topic_iam_member" "audit_logging_publisher" {
  project = var.prod_project_id
  topic   = var.internal_pubsub_topics["audit_events"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:audit-logging-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_subscription_iam_member" "audit_logging_subscriber" {
  project      = var.prod_project_id
  subscription = var.internal_pubsub_subscriptions["audit_sub"]
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:audit-logging-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_subscription_iam_member" "data_integration_subscriber" {
  project      = var.prod_project_id
  subscription = var.internal_pubsub_subscriptions["data_integration_sub"]
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:data-integration-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

##############################################################################
# SECRET MANAGER — secret-level bindings
##############################################################################

resource "google_secret_manager_secret_iam_member" "ehr_core_db_password" {
  project   = var.prod_project_id
  secret_id = "ehr-core-db-password"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:ehr-core-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_secret_manager_secret_iam_member" "pharmacy_mgmt_db_password" {
  project   = var.prod_project_id
  secret_id = "pharmacy-mgmt-db-password"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:pharmacy-mgmt-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_secret_manager_secret_iam_member" "billing_platform_api_key" {
  project   = var.prod_project_id
  secret_id = "billing-clearinghouse-api-key"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:billing-platform-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_secret_manager_secret_iam_member" "identity_svc_okta_secret" {
  project   = var.prod_project_id
  secret_id = "identity-svc-okta-client-secret"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:identity-svc-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_project_iam_audit_config" "project_data_access_audit_config" {
  project = var.prod_project_id
  service = "allServices"

  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}
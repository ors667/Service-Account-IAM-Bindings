##############################################################################
# service_accounts.tf
# Meridian Health — Service Account Infrastructure
#
# Creates all application service accounts for the Meridian Health platform.
# Service accounts are identity-only resources. No IAM role bindings are
# defined in this file — see iam_bindings.tf.
#
# Policy references:
#   - Service Account Naming and Registration Policy (Confluence)
#   - PHI Data Access Policy — Service Accounts (Confluence)
##############################################################################

locals {

  ##
  ## Application definitions.
  ## Each entry maps an app shortname to its metadata.
  ## These drive both service account creation and label enforcement.
  ##
  applications = {

    # -------------------------------------------------------------------------
    # PHI-bearing applications (data_classification = "phi")
    # These service accounts are subject to the PHI Data Access Policy.
    # -------------------------------------------------------------------------

    "ehr-core" = {
      display_name     = "EHR Core System"
      description      = "Service account for EHR Core System (prod) — Clinical Engineering. Handles HL7 FHIR API requests to Cloud SQL and GCS."
      team             = "clinical-engineering"
      data_class       = "phi"
      hipaa_in_scope   = "true"
      cost_center      = ""
      env              = "prod"
    }

    "patient-portal" = {
      display_name     = "Patient Self-Service Portal"
      description      = "Service account for Patient Self-Service Portal (prod) — Digital Health. Manages patient-facing read access to FHIR resources."
      team             = "digital-health"
      data_class       = "phi"
      hipaa_in_scope   = "true"
      cost_center      = "cc-1011"
      env              = "my-test-bed"
    }

    "clinical-imaging" = {
      display_name     = "Clinical Imaging (DICOM)"
      description      = "Service account for Clinical Imaging (prod) — Clinical Engineering. Reads and writes DICOM objects to GCS imaging buckets."
      team             = "clinical-engineering"
      data_class       = "phi"
      hipaa_in_scope   = "true"
      cost_center      = "cc-1012"
      env              = "prod"
    }

    "lab-systems" = {
      display_name     = "Laboratory Information System"
      description      = "Service account for Laboratory Information System (prod) — Clinical Engineering. Manages lab order and result data in Cloud SQL."
      team             = "clinical-engineering"
      data_class       = "phi"
      hipaa_in_scope   = "true"
      cost_center      = "cc-1013"
      env              = "prod"
    }

    "pharmacy-mgmt" = {
      display_name     = "Pharmacy Management"
      description      = "Service account for Pharmacy Management (prod) — Clinical Engineering. Reads and writes prescription records to Cloud SQL."
      team             = "clinical-engineering"
      data_class       = "phi"
      hipaa_in_scope   = "true"
      cost_center      = "cc-1014"
      env              = "prod"
    }

    "care-coordination" = {
      display_name     = "Care Coordination Platform"
      description      = "Service account for Care Coordination Platform (prod) — Clinical Engineering. Accesses clinical care plan records in Cloud SQL."
      team             = "clinical-engineering"
      data_class       = "phi"
      hipaa_in_scope   = "true"
      cost_center      = "cc-1015"
      env              = "prod"
    }

    "clinical-notes" = {
      display_name     = "Clinical Documentation"
      description      = "Service account for Clinical Documentation (prod) — Clinical Engineering. Reads and writes clinical notes to GCS and Cloud SQL."
      team             = "clinical-engineering"
      data_class       = "phi"
      hipaa_in_scope   = "true"
      cost_center      = "cc-1016"
      env              = "prod"
    }

    "medication-admin" = {
      display_name     = "Medication Administration Records"
      description      = "Service account for Medication Administration Records (prod) — Clinical Engineering. Reads MAR data from Cloud SQL."
      team             = "clinical-engineering"
      data_class       = "phi"
      hipaa_in_scope   = "true"
      cost_center      = "cc-1017"
      env              = "prod"
    }

    "referral-mgmt" = {
      display_name     = "Referral Management"
      description      = "Service account for Referral Management (prod) — Digital Health. Reads patient referral records and publishes FHIR events."
      team             = "digital-health"
      data_class       = "phi"
      hipaa_in_scope   = "true"
      cost_center      = "cc-1018"
      env              = "prod"
    }

    "telehealth" = {
      display_name     = "Telehealth Platform"
      description      = "Service account for Telehealth Platform (prod) — Digital Health. Manages telehealth session records and patient PHI access."
      team             = "digital-health"
      data_class       = "phi"
      hipaa_in_scope   = "true"
      cost_center      = "cc-1019"
      env              = "prod"
    }

    "device-integration" = {
      display_name     = "Medical Device Integration"
      description      = "Service account for Medical Device Integration (prod) — Clinical Engineering. Ingests telemetry from bedside devices via Pub/Sub."
      team             = "clinical-engineering"
      data_class       = "phi"
      hipaa_in_scope   = "true"
      cost_center      = "cc-1020"
      env              = "prod"
    }

    "radiology" = {
      display_name     = "Radiology Workflow"
      description      = "Service account for Radiology Workflow (prod) — Clinical Engineering. Reads radiology orders and writes reports to Cloud SQL."
      team             = "clinical-engineering"
      data_class       = "phi"
      hipaa_in_scope   = "true"
      cost_center      = "cc-1021"
      env              = "prod"
    }

    # -------------------------------------------------------------------------
    # Non-PHI applications
    # -------------------------------------------------------------------------

    "billing-platform" = {
      display_name     = "Revenue Cycle and Billing"
      description      = "Service account for Revenue Cycle and Billing (prod) — Finance Engineering. Processes claims and integrates with external clearinghouses."
      team             = "finance-engineering"
      data_class       = "internal"
      hipaa_in_scope   = "false"
      cost_center      = "cc-2010"
      env              = "prod"
    }

    "scheduling-svc" = {
      display_name     = "Appointment Scheduling"
      description      = "Service account for Appointment Scheduling (prod) — Digital Health. Manages appointment slots and patient notifications."
      team             = "digital-health"
      data_class       = "pii"
      hipaa_in_scope   = "false"
      cost_center      = "cc-2011"
      env              = "prod"
    }

    "hr-platform" = {
      display_name     = "Human Resources Platform"
      description      = "Service account for HR Platform (prod) — Corporate Engineering. Manages employee records and HR workflows."
      team             = "corporate-engineering"
      data_class       = "pii"
      hipaa_in_scope   = "false"
      cost_center      = "cc-2012"
      env              = "prod"
    }

    "supply-chain" = {
      display_name     = "Supply Chain Management"
      description      = "Service account for Supply Chain Management (prod) — Operations Engineering. Manages inventory and procurement workflows."
      team             = "operations-engineering"
      data_class       = "internal"
      hipaa_in_scope   = "false"
      cost_center      = "cc-2013"
      env              = "prod"
    }

    "facilities-mgmt" = {
      display_name     = "Facilities Management"
      description      = "Service account for Facilities Management (prod) — Operations Engineering. Manages building systems and maintenance schedules."
      team             = "operations-engineering"
      data_class       = "internal"
      hipaa_in_scope   = "false"
      cost_center      = "cc-2014"
      env              = "prod"
    }

    "analytics-platform" = {
      display_name     = "Business Intelligence"
      description      = "Service account for Business Intelligence (prod) — Data Engineering. Runs analytics queries on internal datasets."
      team             = "data-engineering"
      data_class       = "internal"
      hipaa_in_scope   = "false"
      cost_center      = "cc-2015"
      env              = "prod"
    }

    "identity-svc" = {
      display_name     = "Identity Provider Integration"
      description      = "Service account for Identity Provider Integration (prod) — Platform Engineering. Integrates with Okta and manages token validation."
      team             = "platform-eng"
      data_class       = "internal"
      hipaa_in_scope   = "false"
      cost_center      = "cc-2016"
      env              = "prod"
    }

    "notification-svc" = {
      display_name     = "Notifications and Alerts"
      description      = "Service account for Notifications and Alerts (prod) — Platform Engineering. Publishes and consumes notification events via Pub/Sub."
      team             = "platform-eng"
      data_class       = "internal"
      hipaa_in_scope   = "false"
      cost_center      = "cc-2017"
      env              = "prod"
    }

    "document-mgmt" = {
      display_name     = "Document Management"
      description      = "Service account for Document Management (prod) — Corporate Engineering. Manages non-clinical documents and policies in GCS."
      team             = "corporate-engineering"
      data_class       = "internal"
      hipaa_in_scope   = "false"
      cost_center      = "cc-2018"
      env              = "prod"
    }

    "audit-logging" = {
      display_name     = "Audit and Compliance Logging"
      description      = "Service account for Audit and Compliance Logging (prod) — Platform Engineering. Writes audit events and reads log sinks."
      team             = "platform-eng"
      data_class       = "internal"
      hipaa_in_scope   = "false"
      cost_center      = "cc-2019"
      env              = "prod"
    }

    "api-gateway" = {
      display_name     = "API Gateway"
      description      = "Service account for API Gateway (prod) — Platform Engineering. Routes API requests and validates JWT tokens."
      team             = "platform-eng"
      data_class       = "internal"
      hipaa_in_scope   = "false"
      cost_center      = "cc-2020"
      env              = "prod"
    }

    "data-integration" = {
      display_name     = "Data Integration and ETL"
      description      = "Service account for Data Integration and ETL (prod) — Data Engineering. Runs ETL pipelines between internal systems and BigQuery."
      team             = "data-engineering"
      data_class       = "internal"
      hipaa_in_scope   = "false"
      cost_center      = "cc-2021"
      env              = "prod"
    }

    "reporting-svc" = {
      display_name     = "Regulatory Reporting"
      description      = "Service account for Regulatory Reporting (prod) — Data Engineering. Generates CMS and state regulatory reports from internal datasets."
      team             = "data-engineering"
      data_class       = "internal"
      hipaa_in_scope   = "false"
      cost_center      = "cc-2022"
      env              = "prod"
    }

  }
}

##############################################################################
# Service Account Resources
##############################################################################

resource "google_service_account" "app" {
  for_each = local.applications

  project      = each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id
  account_id   = "${each.key}-${each.value.env}-svc"
  display_name = each.value.display_name
  description  = each.value.description
}

##############################################################################
# Service Account Labels
# Applied via google_service_account_iam_policy is not the right vehicle;
# labels are tracked here as a separate tagging resource.
# Note: requires google provider >= 4.75 for label support on SAs.
##############################################################################

resource "google_tags_tag_binding" "app_labels" {
  for_each = local.applications

  parent    = "//iam.googleapis.com/projects/${each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id}/serviceAccounts/${each.key}-${each.value.env}-svc@${each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id}.iam.gserviceaccount.com"
  tag_value = "tagValues/meridian-app-${each.key}"
}

##############################################################################
# Resource Manager Tag Bindings for Required Label Equivalents
# These enforce the label policy from Confluence Page 1 at the GCP
# Resource Manager level for auditability.
##############################################################################

resource "google_project_iam_custom_role" "sa_metadata" {
  for_each = local.applications

  role_id     = "saMetadata_${replace(each.key, "-", "_")}_${each.value.env}"
  project     = each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id
  title       = "SA Metadata — ${each.value.display_name}"
  description = "Metadata role for service account ${each.key}-${each.value.env}-svc. app=${each.key} env=${each.value.env} owner=${each.value.team} data-classification=${each.value.data_class} hipaa-in-scope=${each.value.hipaa_in_scope} cost-center=${each.value.cost_center} managed-by=terraform"
  permissions = []
  stage       = "GA"
}

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2023_12_29_162205) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.string "full_name"
    t.boolean "primary", default: false, null: false
    t.integer "foundation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "starting_balance_cents", limit: 8, default: 0, null: false
    t.integer "balance_cents", limit: 8, default: 0, null: false
    t.index ["foundation_id"], name: "index_bank_accounts_on_foundation_id"
  end

  create_table "checks", force: :cascade do |t|
    t.integer "check_number"
    t.datetime "transaction_at"
    t.integer "transaction_type"
    t.string "description"
    t.integer "amount_cents", limit: 8, default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.boolean "cleared", default: false, null: false
    t.integer "bank_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_voided", default: false, null: false
    t.integer "funding_source_id"
    t.index ["bank_account_id"], name: "index_checks_on_bank_account_id"
    t.index ["funding_source_id"], name: "index_checks_on_funding_source_id"
  end

  create_table "commitments", force: :cascade do |t|
    t.string "code"
    t.integer "number_payments"
    t.integer "amount_cents", limit: 8, default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "completed", default: false
    t.index ["organization_id"], name: "index_commitments_on_organization_id"
  end

  create_table "contributions", force: :cascade do |t|
    t.string "note"
    t.integer "donor_id", null: false
    t.integer "organization_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "commitment_id"
    t.string "agreement_type"
    t.integer "agreement_id"
    t.index ["agreement_type", "agreement_id"], name: "index_contributions_on_agreement"
    t.index ["commitment_id"], name: "index_contributions_on_commitment_id"
    t.index ["donor_id"], name: "index_contributions_on_donor_id"
    t.index ["organization_id"], name: "index_contributions_on_organization_id"
  end

  create_table "donors", force: :cascade do |t|
    t.string "code"
    t.string "full_name"
    t.integer "foundation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["foundation_id"], name: "index_donors_on_foundation_id"
  end

  create_table "email_verification_tokens", force: :cascade do |t|
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_email_verification_tokens_on_user_id"
  end

  create_table "foundations", force: :cascade do |t|
    t.string "short_name"
    t.string "long_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "funding_sources", force: :cascade do |t|
    t.string "code"
    t.string "short_name"
    t.string "full_name"
    t.integer "foundation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["foundation_id"], name: "index_funding_sources_on_foundation_id"
  end

  create_table "funds_transfers", force: :cascade do |t|
    t.datetime "transaction_at"
    t.string "description"
    t.integer "amount_cents", limit: 8, default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "funding_source_id"
    t.index ["funding_source_id"], name: "index_funds_transfers_on_funding_source_id"
  end

  create_table "in_kinds", force: :cascade do |t|
    t.datetime "transaction_at"
    t.string "description"
    t.integer "value_cents", limit: 8, default: 0, null: false
    t.string "value_currency", default: "USD", null: false
    t.integer "type_of"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organization_types", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.integer "foundation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["foundation_id"], name: "index_organization_types_on_foundation_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.string "alpha"
    t.string "tax_number"
    t.string "contact"
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "country"
    t.integer "foundation_id", null: false
    t.integer "organization_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["foundation_id"], name: "index_organizations_on_foundation_id"
    t.index ["organization_type_id"], name: "index_organizations_on_organization_type_id"
  end

  create_table "password_reset_tokens", force: :cascade do |t|
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "reconciliation_items", force: :cascade do |t|
    t.integer "reconciliation_id", null: false
    t.integer "check_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["check_id"], name: "index_reconciliation_items_on_check_id"
    t.index ["reconciliation_id"], name: "index_reconciliation_items_on_reconciliation_id"
  end

  create_table "reconciliations", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer "starting_balance_cents", limit: 8, default: 0, null: false
    t.string "starting_balance_currency", default: "USD", null: false
    t.integer "ending_balance_cents", limit: 8, default: 0, null: false
    t.string "ending_balance_currency", default: "USD", null: false
    t.integer "bank_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_reconciliations_on_bank_account_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bank_accounts", "foundations"
  add_foreign_key "checks", "bank_accounts"
  add_foreign_key "commitments", "organizations"
  add_foreign_key "contributions", "donors"
  add_foreign_key "contributions", "organizations"
  add_foreign_key "donors", "foundations"
  add_foreign_key "email_verification_tokens", "users"
  add_foreign_key "funding_sources", "foundations"
  add_foreign_key "organization_types", "foundations"
  add_foreign_key "organizations", "foundations"
  add_foreign_key "organizations", "organization_types"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "reconciliation_items", "checks"
  add_foreign_key "reconciliation_items", "reconciliations"
  add_foreign_key "reconciliations", "bank_accounts"
  add_foreign_key "sessions", "users"
end

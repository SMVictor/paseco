# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_11_002608) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "province"
    t.string "canton"
    t.string "district"
  end

  create_table "areas", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bac_infos", force: :cascade do |t|
    t.string "plan"
    t.string "shipping"
    t.string "date"
    t.string "concept"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bncr_infos", force: :cascade do |t|
    t.string "date"
    t.string "company"
    t.string "transfer_type"
    t.string "consecutive"
    t.string "concept"
    t.string "account"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "employee_concept"
  end

  create_table "budget_lines", force: :cascade do |t|
    t.string "salary"
    t.bigint "budget_id"
    t.bigint "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_id"], name: "index_budget_lines_on_budget_id"
    t.index ["employee_id"], name: "index_budget_lines_on_employee_id"
  end

  create_table "budgets", force: :cascade do |t|
    t.string "total_stall"
    t.string "salary"
    t.string "vacations"
    t.string "holidays"
    t.string "total_budget"
    t.string "difference"
    t.string "social_charges"
    t.string "cs_difference"
    t.bigint "stall_id"
    t.bigint "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_budgets_on_role_id"
    t.index ["stall_id"], name: "index_budgets_on_stall_id"
  end

  create_table "ccss_payments", force: :cascade do |t|
    t.float "percentage"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "retired_percentage"
  end

  create_table "christmas_bonification_lines", force: :cascade do |t|
    t.string "base_salary"
    t.string "extra_payment"
    t.string "viaticals"
    t.string "total"
    t.string "start_date"
    t.string "end_date"
    t.bigint "christmas_bonification_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["christmas_bonification_id"], name: "index_christmas_bonification_lines_on_christmas_bonification_id"
  end

  create_table "christmas_bonifications", force: :cascade do |t|
    t.string "from_date"
    t.string "to_date"
    t.string "total"
    t.bigint "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bank"
    t.string "account"
    t.string "name"
    t.index ["employee_id"], name: "index_christmas_bonifications_on_employee_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "business_name"
    t.string "tradename"
    t.string "representative_id"
    t.string "representative_name"
    t.string "legal_document"
    t.string "start_date"
    t.string "end_date"
    t.string "contact"
    t.string "email"
    t.string "email_1"
    t.string "email_2"
    t.string "phone_number"
    t.string "phone_number_1"
    t.string "payment_method"
    t.string "payment_conditions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document"
    t.boolean "active", default: true
    t.bigint "sector_id"
    t.index ["sector_id"], name: "index_customers_on_sector_id"
  end

  create_table "detail_lines", force: :cascade do |t|
    t.string "date"
    t.string "substall"
    t.string "hours"
    t.string "salary"
    t.string "holiday"
    t.string "extra_hours"
    t.string "extra_salary"
    t.string "viatical"
    t.string "extra_payment"
    t.string "extra_payment_reason"
    t.string "deductions"
    t.string "deductions_reason"
    t.string "comments"
    t.bigint "stall_id"
    t.bigint "shift_id"
    t.bigint "payrole_detail_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sector"
    t.string "sub_service"
    t.string "stall_type"
    t.string "shift_name"
    t.string "stall_name"
    t.string "service"
    t.string "employee_name"
    t.bigint "role_line_id"
    t.index ["payrole_detail_id"], name: "index_detail_lines_on_payrole_detail_id"
    t.index ["role_line_id"], name: "index_detail_lines_on_role_line_id"
    t.index ["shift_id"], name: "index_detail_lines_on_shift_id"
    t.index ["stall_id"], name: "index_detail_lines_on_stall_id"
  end

  create_table "disabilities", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.bigint "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "institution"
    t.string "document"
    t.index ["employee_id"], name: "index_disabilities_on_employee_id"
  end

  create_table "downloads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.string "name"
    t.string "gender"
    t.string "id_type"
    t.string "identification"
    t.string "birthday"
    t.string "start_date"
    t.string "end_date"
    t.string "province"
    t.string "canton"
    t.string "district"
    t.string "other"
    t.string "phone"
    t.string "phone_1"
    t.string "emergency_contact"
    t.string "emergency_number"
    t.string "payment_method"
    t.string "bank"
    t.string "account"
    t.string "ccss_number"
    t.string "social_security"
    t.string "daily_viatical"
    t.string "ccss_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "special", default: false
    t.string "document"
    t.boolean "active", default: true
    t.string "account_owner"
    t.string "account_identification"
    t.boolean "registered_account", default: false
    t.string "email"
    t.boolean "retired", default: false
    t.boolean "has_christmas_bonus", default: true
    t.float "own_ccss_deduction"
  end

  create_table "employees_positions", id: false, force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "position_id", null: false
    t.index ["employee_id", "position_id"], name: "index_employees_positions_on_employee_id_and_position_id"
  end

  create_table "employees_stalls", id: false, force: :cascade do |t|
    t.bigint "stall_id", null: false
    t.bigint "employee_id", null: false
    t.index ["stall_id", "employee_id"], name: "index_employees_stalls_on_stall_id_and_employee_id"
  end

  create_table "employees_sub_services", id: false, force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "sub_service_id", null: false
    t.index ["employee_id", "sub_service_id"], name: "index_employees_sub_services_on_employee_id_and_sub_service_id"
  end

  create_table "entries", force: :cascade do |t|
    t.string "start_date"
    t.string "end_date"
    t.string "reason_departure"
    t.string "document"
    t.bigint "customer_id"
    t.bigint "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "sortable_date"
    t.index ["customer_id"], name: "index_entries_on_customer_id"
    t.index ["employee_id"], name: "index_entries_on_employee_id"
  end

  create_table "extra_payroles", force: :cascade do |t|
    t.string "name"
    t.string "from_date"
    t.string "to_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "holidays", force: :cascade do |t|
    t.string "name"
    t.string "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movements", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.string "affair"
    t.string "way"
    t.float "amount"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "employee_id"
    t.index ["employee_id"], name: "index_movements_on_employee_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "Activo"
  end

  create_table "payrole_details", force: :cascade do |t|
    t.string "worked_days"
    t.string "base_salary"
    t.string "extra_hours"
    t.string "extra_salary"
    t.string "viatical"
    t.string "extra_payments"
    t.string "deductions"
    t.string "gross_salary"
    t.string "ccss_deduction"
    t.string "net_salary"
    t.bigint "role_id"
    t.bigint "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "employee_name"
    t.index ["employee_id"], name: "index_payrole_details_on_employee_id"
    t.index ["role_id"], name: "index_payrole_details_on_role_id"
  end

  create_table "payrole_lines", force: :cascade do |t|
    t.string "min_salary"
    t.string "extra_hours"
    t.string "daily_viatical"
    t.string "ccss_deduction"
    t.string "net_salary"
    t.string "extra_payments"
    t.string "deductions"
    t.bigint "role_id"
    t.bigint "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "num_extra_hours"
    t.string "num_worked_days"
    t.string "holidays"
    t.string "bank"
    t.string "account"
    t.string "social_security"
    t.string "ccss_type"
    t.string "name"
    t.index ["employee_id"], name: "index_payrole_lines_on_employee_id"
    t.index ["role_id"], name: "index_payrole_lines_on_role_id"
  end

  create_table "positions", force: :cascade do |t|
    t.string "name"
    t.string "salary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "daily_viatical"
    t.string "hours"
    t.bigint "area_id"
    t.index ["area_id"], name: "index_positions_on_area_id"
  end

  create_table "quote_copies", force: :cascade do |t|
    t.string "institution"
    t.string "procedure_number"
    t.string "procedure_description"
    t.integer "payment_id"
    t.string "daily_salary"
    t.string "night_salary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quotes", force: :cascade do |t|
    t.string "type"
    t.string "institution"
    t.string "procedure_number"
    t.string "procedure_description"
    t.string "officers"
    t.string "holidays"
    t.string "vacations"
    t.bigint "payment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "daily_salary"
    t.string "night_salary"
    t.string "status"
    t.serial "number", null: false
    t.index ["payment_id"], name: "index_quotes_on_payment_id"
  end

  create_table "requirements", force: :cascade do |t|
    t.string "hours"
    t.string "workers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "shift_id"
    t.bigint "position_id"
    t.bigint "quote_id"
    t.string "start_day"
    t.string "end_day"
    t.string "freeday_worker"
    t.index ["position_id"], name: "index_requirements_on_position_id"
    t.index ["quote_id"], name: "index_requirements_on_quote_id"
    t.index ["shift_id"], name: "index_requirements_on_shift_id"
  end

  create_table "role_lines", force: :cascade do |t|
    t.string "date"
    t.string "substall"
    t.string "hours"
    t.bigint "role_id"
    t.bigint "employee_id"
    t.bigint "stall_id"
    t.bigint "shift_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "comment"
    t.string "extra_payments"
    t.string "extra_payments_description"
    t.string "deductions"
    t.string "deductions_description"
    t.boolean "holiday", default: false
    t.bigint "position_id"
    t.string "requirement_justification"
    t.bigint "sub_service_id"
    t.string "start_date"
    t.time "start_hour"
    t.string "end_date"
    t.time "end_hour"
    t.string "user_email"
    t.index ["employee_id"], name: "index_role_lines_on_employee_id"
    t.index ["position_id"], name: "index_role_lines_on_position_id"
    t.index ["role_id"], name: "index_role_lines_on_role_id"
    t.index ["shift_id"], name: "index_role_lines_on_shift_id"
    t.index ["stall_id"], name: "index_role_lines_on_stall_id"
    t.index ["sub_service_id"], name: "index_role_lines_on_sub_service_id"
  end

  create_table "role_lines_copies", force: :cascade do |t|
    t.string "date"
    t.string "substall"
    t.string "hours"
    t.integer "employee_id"
    t.integer "shift_id"
    t.integer "stall_id"
    t.integer "role_id"
    t.string "comment"
    t.string "action"
    t.bigint "role_line_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "holiday", default: false
    t.index ["role_line_id"], name: "index_role_lines_copies_on_role_line_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "start_date"
    t.string "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_stalls", id: false, force: :cascade do |t|
    t.bigint "stall_id", null: false
    t.bigint "role_id", null: false
    t.index ["stall_id", "role_id"], name: "index_roles_stalls_on_stall_id_and_role_id"
  end

  create_table "sectors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shifts", force: :cascade do |t|
    t.string "name"
    t.string "time"
    t.string "cost"
    t.string "extra_time_cost"
    t.bigint "payment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "start_hour"
    t.boolean "active", default: true
    t.index ["payment_id"], name: "index_shifts_on_payment_id"
  end

  create_table "stalls", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "province"
    t.string "canton"
    t.string "district"
    t.string "other"
    t.string "daily_viatical"
    t.string "extra_shift"
    t.string "substalls"
    t.bigint "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.bigint "quote_id"
    t.bigint "type_id"
    t.boolean "send_payslips", default: false
    t.index ["customer_id"], name: "index_stalls_on_customer_id"
    t.index ["quote_id"], name: "index_stalls_on_quote_id"
    t.index ["type_id"], name: "index_stalls_on_type_id"
  end

  create_table "stalls_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "stall_id", null: false
    t.index ["user_id", "stall_id"], name: "index_stalls_users_on_user_id_and_stall_id"
  end

  create_table "sub_services", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "service_id"
    t.string "service_name"
    t.index ["service_id"], name: "index_sub_services_on_service_id"
  end

  create_table "types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "name", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.string "identification"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vacations", force: :cascade do |t|
    t.string "start_date"
    t.string "end_date"
    t.string "requested_days"
    t.string "included_freedays"
    t.bigint "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "period"
    t.string "date"
    t.index ["employee_id"], name: "index_vacations_on_employee_id"
  end

  create_table "work_role_lines", force: :cascade do |t|
    t.date "date"
    t.string "sub_stall"
    t.bigint "work_role_id"
    t.bigint "employee_id"
    t.bigint "stall_id"
    t.bigint "shift_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_work_role_lines_on_employee_id"
    t.index ["shift_id"], name: "index_work_role_lines_on_shift_id"
    t.index ["stall_id"], name: "index_work_role_lines_on_stall_id"
    t.index ["work_role_id"], name: "index_work_role_lines_on_work_role_id"
  end

  create_table "work_roles", force: :cascade do |t|
    t.string "name"
    t.string "start_date"
    t.string "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "budget_lines", "budgets"
  add_foreign_key "budget_lines", "employees"
  add_foreign_key "budgets", "roles"
  add_foreign_key "budgets", "stalls"
  add_foreign_key "christmas_bonification_lines", "christmas_bonifications"
  add_foreign_key "christmas_bonifications", "employees"
  add_foreign_key "customers", "sectors"
  add_foreign_key "detail_lines", "payrole_details"
  add_foreign_key "detail_lines", "role_lines"
  add_foreign_key "detail_lines", "shifts"
  add_foreign_key "detail_lines", "stalls"
  add_foreign_key "payrole_details", "employees"
  add_foreign_key "payrole_details", "roles"
  add_foreign_key "positions", "areas"
  add_foreign_key "quotes", "payments"
  add_foreign_key "requirements", "positions"
  add_foreign_key "requirements", "quotes"
  add_foreign_key "requirements", "shifts"
  add_foreign_key "role_lines", "positions"
  add_foreign_key "role_lines", "sub_services"
  add_foreign_key "stalls", "quotes"
  add_foreign_key "stalls", "types"
  add_foreign_key "sub_services", "services"
  add_foreign_key "vacations", "employees"
end

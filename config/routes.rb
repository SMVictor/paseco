Rails.application.routes.draw do

  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'

  #DEVISE ROUTES  
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    invitations: 'users/invitations',
    passwords: 'users/passwords'
  }

  authenticated :user do

    root  'admin/pages#home',                as: 'authenticated_root'
    patch '/' => 'admin/pages#update_home',  as: 'update_home'
    
    namespace :admin do
      resources :roles
      resources :users
      resources :areas
      resources :stalls
      resources :quotes
      resources :holidays
      resources :payments
      resources :bac_infos
      resources :customers
      resources :employees
      resources :positions
      resources :bncr_infos
      resources :work_roles
      resources :ccss_payments
      resources :movements

      get    'roles/lines/:id/:stall_id/:employee_id'           => 'roles#add_role_lines',    as: 'role_lines'
      patch  'roles/lines/:id/:stall_id/:employee_id'           => 'roles#update_role_lines', as: 'edit_role_lines'

      get    'roles/approvals/:id'                              => 'roles#approvals',         as: 'role_approvals'
      get    'roles/approvals/:id/:stall_id'                    => 'roles#check_changes',     as: 'check_role_changes'
      get    'roles/approvals/add/:id/:stall_id/:change_id'     => 'roles#approve_create',    as: 'approve_create'
      get    'roles/approvals/update/:id/:stall_id/:change_id'  => 'roles#approve_update',    as: 'approve_update'
      get    'roles/approvals/destroy/:id/:stall_id/:change_id' => 'roles#approve_destroy',   as: 'approve_destroy'
      get    'roles/approvals/deny/:id/:stall_id/:change_id'    => 'roles#deny_change',       as: 'deny_change'

      get    'payroles'                                      => 'roles#index_payroles',         as: 'payroles'
      get    'payroles/:id'                                  => 'roles#show_payroles',          as: 'payrole'
      get    'payroles/:id/:employee_id'                     => 'roles#payrole_detail',         as: 'payrole_detail'
      get    'payroles/:id/employees/:employee_id/file'      => 'roles#payrole_detail_pdf',     as: 'payrole_detail_pdf'
      get    'payroles/:id/employees/:employee_id/email'     => 'roles#payrole_detail_email',   as: 'payrole_detail_email'
      patch  'payroles/edit/lines/:id/:employee_id/:line_id' => 'roles#update_payrole_line',    as: 'update_payrole_line'
      get    'payroles/:id/email/send'                       => 'roles#send_payslips',          as: 'send_payslips'
      post   'payroles/load'                                 => 'roles#load_payrole',           as: 'load_payrole'
      get    'bonuses'                                       => 'extra_payroles#index',         as: 'extra_payroles'
      get    'bonuse'                                        => 'extra_payroles#new',           as: 'extra_payrole'
      post   'bonuse'                                        => 'extra_payroles#create',        as: 'extra_payrole_create'
      get    'bonuses/:id'                                   => 'extra_payroles#show',          as: 'extra_payroles_show'
      get    'bonuses/BNCR/file/:id'                         => 'extra_payroles#bncr_file',     as: 'bonuses_bncr_file'
      get    'bonuses/BAC/file/:id'                          => 'extra_payroles#bac_file',      as: 'bonuses_bac_file'
      get    'bonuses/:employee_id/:extra_payrole'           => 'extra_payroles#edit_bonuses',  as: 'edit_bonuses'
      patch  'bonuses/:employee_id/:bonus'                   => 'extra_payroles#update_bonuses',as: 'update_bonuses'

      get    'BNCR/file/:id' => 'roles#bncr_file', as: 'bncr_file'
      get    'BAC/file/:id'  => 'roles#bac_file',  as: 'bac_file'

      get    'inactive/customers'          => 'customers#inactives',        as: 'inactive_customers'
      get    'inactive/customers/:id'      => 'customers#show_inactive',    as: 'show_inactive_customer'
      get    'inactive/customers/:id/edit' => 'customers#edit_inactive',    as: 'edit_inactive_customer'
      patch  'inactive/customers/:id/edit' => 'customers#update_inactive',  as: 'update_inactive_customer'
      delete 'inactive/customers/:id/edit' => 'customers#destroy_inactive', as: 'delete_inactive_customer'

      get    'inactive/stalls'          => 'stalls#inactives',        as: 'inactive_stalls'
      get    'inactive/stalls/:id'      => 'stalls#show_inactive',    as: 'show_inactive_stall'
      get    'inactive/stalls/:id/edit' => 'stalls#edit_inactive',    as: 'edit_inactive_stall'
      patch  'inactive/stalls/:id/edit' => 'stalls#update_inactive',  as: 'update_inactive_stall'
      delete 'inactive/stalls/:id/edit' => 'stalls#destroy_inactive', as: 'delete_inactive_stall'

      get    'inactive/employees'          => 'employees#inactives',        as: 'inactive_employees'
      get    'inactive/employees/:id'      => 'employees#show_inactive',    as: 'show_inactive_employee'
      get    'inactive/employees/:id/edit' => 'employees#edit_inactive',    as: 'edit_inactive_employee'
      patch  'inactive/employees/:id/edit' => 'employees#update_inactive',  as: 'update_inactive_employee'
      delete 'inactive/employees/:id/edit' => 'employees#destroy_inactive', as: 'delete_inactive_employee'

      get    'roles/:id/stalls/:stall_id'  => 'roles#stall_summary',        as: 'stall_summary'

      get    'payroles/:id/stalls/hours'   => 'roles#stalls_hours',         as: 'stalls_hours'

      get    'employees/:id/vacations/file' => 'employees#vacations_file',  as: 'vacations_file'
  
      get    'employee/:id/vacations' => 'employees#edit_vacations',    as: 'edit_vacations'
      patch  'employee/:id/vacations' => 'employees#update_vacations',  as: 'update_vacations'
      get    'employee/:id/vacations/inactive'     => 'employees#edit_vacations_inactive',    as: 'edit_vacations_inactive'
      patch  'employee/:id/vacations/inactive'     => 'employees#update_vacations_inactive',  as: 'update_vacations_inactive'

      get    'quotes/:id/step1' => 'quotes#create_step1', as: 'create_quote_step1'
      patch  'quotes/:id/step1' => 'quotes#update_step1', as: 'update_quote_step1'
      get    'quotes/:id/step2' => 'quotes#create_step2', as: 'create_quote_step2'
      patch  'quotes/:id/step2' => 'quotes#update_step2', as: 'update_quote_step2'

      get    'quotes/:id/step1/edit' => 'quotes#edit_step1',        as: 'edit_quote_step1'
      patch  'quotes/:id/step1/edit' => 'quotes#update_edit_step1', as: 'update_edit_quote_step1'
      delete 'quotes/:id/step1/edit' => 'quotes#restore_step1',     as: 'restore_quote_step1'
      get    'quotes/:id/step2/edit' => 'quotes#edit_step2',        as: 'edit_quote_step2'
      patch  'quotes/:id/step2/edit' => 'quotes#update_edit_step2', as: 'update_edit_quote_step2'

      get    'budget/:id/'             => 'roles#budget',        as: 'budget'
      get    'budget/:id/old'          => 'roles#old_budget',    as: 'old_budget'
      get    'budget/:id/:employee_id' => 'roles#budget_detail', as: 'budget_detail'

      get    'work_roles/lines/:id/:stall_id'           => 'work_roles#add_role_lines',    as: 'work_role_lines'
      get    'work_roles/lines/:id/:stall_id/update'    => 'work_roles#update_role_lines', as: 'work_edit_role_lines'

      get    'downloads'                 => 'downloads#index',           as: 'downloads'
      get    'downloads/inscaja'         => 'downloads#ins_caja',        as: 'inscaja'
      get    'downloads/payroles'        => 'downloads#payroles',        as: 'downloads_payroles'
      get    'downloads/breakdown'       => 'downloads#breakdown',       as: 'downloads_breakdown'
      get    'downloads/entity'          => 'downloads#entity',          as: 'downloads_entity'
      get    'downloads/bonuses'         => 'downloads#bonuses',         as: 'downloads_bonuses'
      get    'downloads/bonus/breakdown' => 'downloads#bonus_breakdown', as: 'downloads_bonus_breakdown'

    end
  end
  
  root 'home#home'
  get '*path' => redirect('/')
  
end

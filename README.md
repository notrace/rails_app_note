# rails_app_note
使用rails开发web-server的笔记

## 注册账户
修改devise, 登录使用phone

- [app/model/user.rb](/app/model/user.rb)
- [config/devise.rb](/config/devise.rb)
- [app/controllers/api/v1/sessions_controller.rb](/app/controllers/api/v1/sessions_controller.rb)

注册
- [app/controllers/api/v1/fwd_controller.rb](/app/controllers/api/v1/fwd_controller.rb)
- [app/controllers/api/v1/registrations_controller.rb](/app/controllers/api/v1/registrations_controller.rb)

忘记密码
- [app/controllers/api/v1/passwords_controller.rb](/app/controllers/api/v1/passwords_controller.rb)

## has_many through 表单管理关系
  has_many :workshops, :dependent => :destroy
  has_many :workshops, through: :workshop_partner_relations
  accepts_nested_attributes_for :workshops

  <%= f.association :partners, label: "合作伙伴", as: :check_boxes, include_blank: false, :item_wrapper_class => 'col-md-3',collection_wrapper_tag:'div' %>

## simple_form association class关系
item_wrapper_class 
collection_wrapper_tag

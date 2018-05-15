class Micropost < ApplicationRecord
  belongs_to :user
  # `-> { puts "foo" }`はラムダ式（Procとも）`.call`で実行する
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end

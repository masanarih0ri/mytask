class Task < ApplicationRecord
  # nameが検証される前に名前が無い場合には「名前なし」というタスク名にする
  # ここはp218で不要となったのでいったん削除
  # before_validation :set_nameless_name

  validates :name, presence: true, length: { maximum: 30 }
  validate :validate_name_not_including_comma

  belongs_to :user

  scope :recent, -> {order(created_at: :desc)}

  private

  # ここはp218で不要となったのでいったん削除
  # def set_nameless_name
  #   self.name = '名前なし' if name.blank?
  # end

  def validate_name_not_including_comma
    errors.add(:name, 'にカンマを含めることはできません') if name&.include?(',')
  end

  # ransack用のカラム範囲の指定
  def self.ransackable_attributes(auth_object = nil)
    %w[name created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end

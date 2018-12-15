class Task < ApplicationRecord
  # 1つのタスクに1つの画像を紐づけること、その画像をTaskモデルからimageを呼ぶことを指定している
  has_one_attached :image
  # nameが検証される前に名前が無い場合には「名前なし」というタスク名にする
  # ここはp218で不要となったのでいったん削除
  # before_validation :set_nameless_name

  validates :name, presence: true, length: { maximum: 30 }
  validate :validate_name_not_including_comma

  belongs_to :user

  scope :recent, -> {order(created_at: :desc)}

  # csvダウンロード用のメソッド
  def self.csv_attributes
    ["name", "description", "created_at", "updated_at"]
  end

  def self.generate_csv
    # csvデータの文字列を生成 上記のクラスメソッドの戻り値は生成した文字列となる
    CSV.generate(headers: true) do |csv|
      csv << csv_attributes
      all.each do |task|
        csv << csv_attributes.map{ |attr| task.send(attr) }
      end
    end
  end

  # csvインポート用のメソッド
  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      task = Task.new
      task.attributes = row.to_hash.slice("name", "description", "created_at", "updated_at")
      task.save!
    end
  end

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

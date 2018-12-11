FactoryBot.define do
  factory :task do
    name { 'テストを書く' }
    description { 'Rspecとかを準備する' }
    user
  end
end

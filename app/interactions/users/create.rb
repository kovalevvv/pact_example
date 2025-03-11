class Users::Create < ActiveInteraction::Base
  string :name, :patronymic, :email, :nationality, :country, :gender
  string :surname, default: nil
  integer :age
  array :interests, default: []
  string :skills, default: ''

  validates :name, :patronymic, :email, :nationality, :country, :gender, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :age, numericality: { greater_than: 0, less_than_or_equal_to: 90 }
  validates :gender, inclusion: { in: %w[male female] }
  validate :email_uniqueness

  def execute
    user_full_name = [surname, name, patronymic].compact.join(' ')
    
    user = User.new(
      name: name,
      patronymic: patronymic,
      surname: surname,
      email: email,
      age: age,
      nationality: nationality,
      country: country,
      gender: gender,
      user_full_name: user_full_name
    )

    # Добавление интересов
    Interest.where(name: interests).each do |interest|
      user.interests << interest
    end

    # Добавление навыков
    processed_skills = skills.split(',').map(&:strip)
    Skill.where(name: processed_skills).each do |skill|
      user.skills << skill
    end

    # Сохраняем пользователя и возвращаем его
    user.save ? user : errors.merge!(user.errors)
  end

  private

  def email_uniqueness
    if User.exists?(email: email)
      errors.add(:email, 'уже занят')
    end
  end
end
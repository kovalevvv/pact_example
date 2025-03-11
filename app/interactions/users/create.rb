class Users::Create < ActiveInteraction::Base
  # Декларативно описываем типы входных параметров
  string :name, :patronymic, :email, :nationality, :country, :gender
  string :surname, default: nil
  integer :age
  array :interests, default: []
  string :skills, default: ''
  
  # Декларативно описываем правила валидации
  validates :name, :patronymic, :email, :nationality, :country, :gender, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :age, numericality: { greater_than: 0, less_than_or_equal_to: 90 }
  validates :gender, inclusion: { in: %w[male female] }
  validate :email_uniqueness
  
  def execute
    # Декларативное описание формирования полного имени
    user_full_name = [surname, name, patronymic].compact.join(' ')
    
    # Создание пользователя с атрибутами
    user = build_user(user_full_name)
    
    # Декларативно описываем связи
    associate_interests(user)
    associate_skills(user)
    
    # Сохраняем и обрабатываем результат
    save_user(user)
  end
  
  private
  
  def build_user(user_full_name)
    User.new(
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
  end
  
  def associate_interests(user)
    Interest.where(name: interests).each do |interest|
      user.interests << interest
    end
  end
  
  def associate_skills(user)
    processed_skills = skills.split(',').map(&:strip)
    Skill.where(name: processed_skills).each do |skill|
      user.skills << skill
    end
  end
  
  def save_user(user)
    user.save ? user : errors.merge!(user.errors)
  end
  
  def email_uniqueness
    errors.add(:email, 'уже занят') if User.exists?(email: email)
  end
end
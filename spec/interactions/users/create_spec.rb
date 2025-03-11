require 'rails_helper'

RSpec.describe Users::Create, type: :interaction do
  describe '#execute' do
    let(:valid_attributes) do
      {
        name: 'Иван',
        patronymic: 'Иванович',
        surname: 'Иванов',
        email: 'ivan@example.com',
        age: 30,
        nationality: 'Русский',
        country: 'Россия',
        gender: 'male',
        interests: ['программирование', 'чтение'],
        skills: 'Ruby, Rails, SQL'
      }
    end

    context 'с валидными данными' do
      it 'создает нового пользователя' do
        expect { Users::Create.run!(valid_attributes) }.to change(User, :count).by(1)
      end

      it 'корректно устанавливает атрибуты пользователя' do
        user = Users::Create.run!(valid_attributes)
        
        expect(user.name).to eq('Иван')
        expect(user.patronymic).to eq('Иванович')
        expect(user.email).to eq('ivan@example.com')
        expect(user.age).to eq(30)
        expect(user.nationality).to eq('Русский')
        expect(user.country).to eq('Россия')
        expect(user.gender).to eq('male')
        expect(user.user_full_name).to eq('Иванов Иван Иванович')
      end

      it 'связывает пользователя с указанными интересами' do
        interest1 = create(:interest, name: 'программирование')
        interest2 = create(:interest, name: 'чтение')
        
        user = Users::Create.run!(valid_attributes)
        
        expect(user.interests).to include(interest1)
        expect(user.interests).to include(interest2)
      end

      it 'связывает пользователя с указанными навыками' do
        skill1 = create(:skil, name: 'Ruby')
        skill2 = create(:skil, name: 'Rails')
        skill3 = create(:skil, name: 'SQL')
        
        user = Users::Create.run!(valid_attributes)
        
        expect(user.skills).to include(skill1)
        expect(user.skills).to include(skill2)
        expect(user.skills).to include(skill3)
      end

      it 'корректно обрабатывает навыки с пробелами' do
        skill = create(:skil, name: 'Ruby')
        attrs = valid_attributes.merge(skills: ' Ruby ')
        
        user = Users::Create.run!(attrs)
        
        expect(user.skills).to include(skill)
      end

      it 'создает пользователя без фамилии' do
        attrs = valid_attributes.merge(surname: nil)
        user = Users::Create.run!(attrs)
        
        expect(user.user_full_name).to eq('Иван Иванович')
      end
    end

    context 'с невалидными данными' do
      it 'не создает пользователя без обязательных полей' do
        required_fields = [:name, :patronymic, :email, :nationality, :country, :gender]
        
        required_fields.each do |field|
          attrs = valid_attributes.merge(field => nil)
          outcome = Users::Create.run(attrs)
          
          expect(outcome).to be_invalid
          expect(outcome.errors[field]).to be_present
        end
      end

      it 'валидирует формат email' do
        attrs = valid_attributes.merge(email: 'invalid-email')
        outcome = Users::Create.run(attrs)
        
        expect(outcome).to be_invalid
        expect(outcome.errors[:email]).to be_present
      end

      it 'валидирует уникальность email' do
        create(:user, email: 'ivan@example.com')
        
        outcome = Users::Create.run(valid_attributes)
        
        expect(outcome).to be_invalid
        expect(outcome.errors[:email]).to include('уже занят')
      end

      it 'валидирует возраст' do
        # Слишком молодой
        attrs = valid_attributes.merge(age: 0)
        outcome = Users::Create.run(attrs)
        expect(outcome).to be_invalid
        
        # Слишком старый
        attrs = valid_attributes.merge(age: 91)
        outcome = Users::Create.run(attrs)
        expect(outcome).to be_invalid
        
        # Граничные значения
        attrs = valid_attributes.merge(age: 1)
        expect(Users::Create.run(attrs)).to be_valid
        
        attrs = valid_attributes.merge(age: 90)
        expect(Users::Create.run(attrs)).to be_valid
      end

      it 'валидирует пол' do
        attrs = valid_attributes.merge(gender: 'other')
        outcome = Users::Create.run(attrs)
        
        expect(outcome).to be_invalid
        expect(outcome.errors[:gender]).to be_present
      end
    end

    context 'при ошибке сохранения модели' do
      it 'передает ошибки модели в ошибки интерактора' do
        # Эмулируем ошибку валидации на уровне модели
        allow_any_instance_of(User).to receive(:valid?).and_return(false)
        allow_any_instance_of(User).to receive(:errors).and_return(
          ActiveModel::Errors.new(User.new).tap { |e| e.add(:base, 'Тестовая ошибка модели') }
        )
        
        outcome = Users::Create.run(valid_attributes)
        
        expect(outcome).to be_invalid
        expect(outcome.errors[:base]).to include('Тестовая ошибка модели')
      end
    end
  end
end
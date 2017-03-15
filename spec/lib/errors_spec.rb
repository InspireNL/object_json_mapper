describe ActiveUMS::Errors do
  let(:user) { User.new }

  context 'using rails 4.2 validation errors' do
    describe '#load_errors' do
      let(:errors) do
        {
          email: ["can't be blank"],
          password: ["is too short", "is too long"]
        }
      end

      it 'correctly loads errors' do
        user.load_errors(errors)

        expect(user.errors.full_messages).to match_array([
          "Email can't be blank",
          "Password is too short",
          "Password is too long"
        ])
      end
    end
  end

  context 'using rails 5.0 validation errors' do
    describe '#load_errors' do
      let(:errors) do
        {
          email: [{ error: :blank }],
          password: [
            { error: :too_short, count: 5 },
            { error: :too_long, count: 10 }
          ]
        }
      end

      it 'correctly loads errors' do
        user.load_errors(errors)
        expect(user.errors.full_messages).to match_array([
          "Email can't be blank",
          "Password is too short (minimum is 5 characters)",
          "Password is too long (maximum is 10 characters)"
        ])
      end
    end
  end
end

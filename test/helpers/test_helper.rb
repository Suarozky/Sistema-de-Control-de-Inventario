# Al final del archivo test/test_helper.rb, agrega:

class ActionDispatch::IntegrationTest
  def sign_in_as(user)
    post sessions_url, params: { 
      name: user.name, 
      lastname: user.lastname 
    }
  end
  
  def sign_out
    delete session_url
  end
end
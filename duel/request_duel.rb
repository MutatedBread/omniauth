require_relative 'duel_helper'

# The request phase, POSTed. It writes to the session and the env, so
# each iteration gets fresh copies, made untimed.
setup { @session = {} }

duel 'request: the developer form' do |n|
  once do
    @strategy = OmniAuth::Strategies::Developer.new(DuelHelper::APP)
    @env = DuelHelper.env_for('/auth/developer', :method => 'POST', :params => {'origin' => '/dashboard'})
  end
  envs = untimed { DuelHelper.fresh_envs(@env, @session, n) }
  DuelHelper.call_each(@strategy, envs, 200)
end

duel 'request: redirect to the provider' do |n|
  once do
    @strategy = DuelHelper::Provider.new(DuelHelper::APP)
    @env = DuelHelper.env_for('/auth/provider', :method => 'POST', :params => {'origin' => '/dashboard'})
  end
  envs = untimed { DuelHelper.fresh_envs(@env, @session, n) }
  DuelHelper.call_each(@strategy, envs, 302)
end

# With as many sign-ins remembered as OmniAuth keeps, so remembering
# another forgets the oldest.
duel 'request: redirect, with five sign-ins kept' do |n|
  once do
    @strategy = DuelHelper::Provider.new(DuelHelper::APP)
    @env = DuelHelper.env_for('/auth/provider', :method => 'POST')
    @full = @session.merge('omniauth.sign_ins' => DuelHelper.sign_ins(OmniAuth::Strategy::SignIns::MAX_REMEMBERED_SIGN_INS))
  end
  envs = untimed { DuelHelper.fresh_envs(@env, @full, n) }
  DuelHelper.call_each(@strategy, envs, 302)
end

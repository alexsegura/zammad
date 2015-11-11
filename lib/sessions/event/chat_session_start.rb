class Sessions::Event::ChatSessionStart < Sessions::Event::ChatBase

  def run

    # find first in waiting list
    chat_session = Chat::Session.where(state: 'waiting').order('created_at ASC').first
    if !chat_session
      return {
        event: 'chat_session_start',
        data: {
          state: 'failed',
          message: 'No session available.',
        },
      }
    end
    chat_session.user_id = @session['id']
    chat_session.state = 'running'
    chat_session.preferences[:participants] = chat_session.add_recipient(@client_id)
    chat_session.save

    # send chat_session_init to client
    chat_user = User.find(chat_session.user_id)
    user = {
      name: chat_user.fullname,
      avatar: chat_user.image,
    }
    data = {
      event: 'chat_session_start',
      data: {
        state: 'ok',
        agent: user,
        session_id: chat_session.session_id,
      },
    }
    chat_session.send_to_recipients(data, @client_id)

    # send chat_session_init to agent
    {
      event: 'chat_session_start',
      data: {
        state: 'ok',
        session: chat_session,
      },
    }
  end
end

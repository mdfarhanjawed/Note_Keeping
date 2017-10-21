class NotesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "note_#{params['note_id']}_channel"
  end

  def unsubscribed
  end

  def send_comment(data)
    current_user.comments.create(content: data['comment'], blog_id: data['blog_id'])
  end
end
# -*- coding: utf-8 -*-

Plugin.create :profile_change do

  # replace user_name()
  Plugin[:profile].instance_eval {
    def user_name_ex(user)
      w_screen_name = ::Gtk::Label.new.set_markup("<b><u><span foreground=\"#0000ff\">#{Pango.escape(user[:idname])}</span></u></b>")
      w_ev = ::Gtk::EventBox.new
      w_ev.modify_bg(::Gtk::STATE_NORMAL, Gdk::Color.new(0xffff, 0xffff, 0xffff))
      w_ev.ssc(:realize) {
        w_ev.window.set_cursor(Gdk::Cursor.new(Gdk::Cursor::HAND2))
        false }
      w_ev.ssc(:button_press_event) { |this, e|
        if e.button == 1
         ::Gtk.openurl("http://twitter.com/#{user[:idname]}")
          true end }

      if user.is_me?
        w_user = ::Gtk::Entry.new()
        w_user.text = user[:name]

        w_user_change = ::Gtk::Button.new("変更")

        w_user_change.ssc(:clicked) { |this|
          w_user_change.sensitive = false
          w_user.sensitive = false

          Service.primary.twitter.api("account/update_profile", {:name=>w_user.text}).next { |result|
            w_user_change.sensitive = true
            w_user.sensitive = true

            if result.code == "200"
              activity :system, "@#{user[:idname]}の名前を#{w_user.text}に変更しました。"
            else
              activity :system, "名前をの変更になんか失敗しました。"
            end
          }
        }

        ::Gtk::HBox.new(false, 16).closeup(w_ev.add(w_screen_name)).closeup(w_user).closeup(w_user_change)
      else
        ::Gtk::HBox.new(false, 16).closeup(w_ev.add(w_screen_name)).closeup(::Gtk::Label.new(user[:name]))
      end
    end

    alias :user_name2 :user_name
    alias :user_name :user_name_ex
  }

end

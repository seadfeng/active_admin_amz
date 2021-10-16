namespace :amz do 

  desc "paapi5"
  task :paapi5 => :environment  do
    pre_page = 10 
    Amz::Store.all.each do |store| 
      next unless store.amz_pai_enabled
      puts "//** ============= Store ##{store.id}"
      products = Amz::Product.published.joins(:amazon).where("amz_products.store_id = ?" ,store.id)
      total_pages = products.page(1).per(pre_page).total_pages

      for i in 1..total_pages do
        wait = 5.seconds + (i*3).seconds
        asins = products.page(i).per(pre_page).pluck(:"amz_amazons.asin")
        puts "BOF ======= #{i}"
        puts asins
        Amz::AmazonPaapi5Job.set(wait: wait ).perform_later( asins: asins , store: store  )
        puts "EOF ======= #{i}"
      end
      puts "============= Store ##{store.id} **//"
    end

  end

  desc "Paapi5 Update blank description"
  task :paapi5_description => :environment  do
    pre_page = 10 
    Amz::Store.all.each do |store| 
      next unless store.amz_pai_enabled
      puts "//** ============= Store ##{store.id}"
      products = Amz::Product.joins(:amazon).where("amz_products.store_id = ? and amz_products.description is null" ,store.id)
      total_pages = products.page(1).per(pre_page).total_pages

      for i in 1..total_pages do
        wait = 5.seconds + (i*3).seconds
        asins = products.page(i).per(pre_page).pluck(:"amz_amazons.asin")
        puts "BOF ======= #{i}"
        puts asins
        Amz::AmazonPaapi5Job.set(wait: wait ).perform_later( asins: asins , store: store  )
        puts "EOF ======= #{i}"
      end
      puts "============= Store ##{store.id} **//"
    end 
  end


  desc "Paapi5 Update draft"
  task :paapi5_draft => :environment  do
    pre_page = 10 
    Amz::Store.all.each do |store| 
      next unless store.amz_pai_enabled
      puts "//** ============= Store ##{store.id}"
      products = Amz::Product.draft.joins(:amazon).where("amz_products.store_id = ?" ,store.id)
      total_pages = products.page(1).per(pre_page).total_pages

      for i in 1..total_pages do
        wait = 5.seconds + (i*3).seconds
        asins = products.page(i).per(pre_page).pluck(:"amz_amazons.asin")
        puts "BOF ======= #{i}"
        puts asins
        Amz::AmazonPaapi5Job.set(wait: wait ).perform_later( asins: asins , store: store  )
        puts "EOF ======= #{i}"
      end
      puts "============= Store ##{store.id} **//"
    end 
  end


  desc "mailer"
  task :mailer => :environment  do
    Amz::Mailer.available.each do |mailer|
      store = mailer.store
      mailer_logs =  mailer.mailer_logs.not_sended.limit(store.preferred_send_per_queue)
      if mailer_logs.any?
        mailer_logs.each do |mailer_log|
          mailer_log.send_mail
        end
        puts "Send mail => #{mailer.subject} (sizes: #{mailer_logs.size})"
      else
        if mailer.build_mailer_logs 
          puts "builded mailer logs => #{mailer.subject} (##{mailer.id})"
        end
      end
    end
  end
  desc "Initial"
  task :init => :environment  do
      Amz::Store.all.each do |store|
        store.blocks.create(identity: 'footer_links', 
          name: 'Footer Links', 
          published_at: Time.current, 
          description: '<div><a class="MuiTypography-root MuiLink-root MuiLink-underlineHover MuiTypography-body1 MuiTypography-colorPrimary" href="/about-us">Sobre Nosotros</a> </div>' ) if store.blocks.find_by_identity('footer_links').blank?

        store.blocks.create(identity: 'app_drawer', 
                          name: 'Drawer', 
                          published_at: Time.current, 
                          description: "About Us 1|/about-us\r\nAbout Us 2|/about-us" ) if store.blocks.find_by_identity('app_drawer').blank?
        store.blocks.create(identity: 'footer_policy', 
                          name: 'Footer Policy', 
                          published_at: Time.current, 
                          description: "Amazon, Amazon Prime, the Amazon logo and Amazon Prime logo are trademarks of Amazon.com, Inc. or its affiliates" ) if store.blocks.find_by_identity('footer_policy').blank?
        store.blocks.create(identity: 'page_not_found', 
          name: 'Page Not Found', 
          published_at: Time.current, 
          description: "Page Not Found<br /><a href='/'>Go to home page</a>" ) if store.blocks.find_by_identity('page_not_found').blank?

        store.blocks.create(identity: 'unsubscription', 
                            name: 'Unsubscription', 
                            published_at: Time.current, 
                            description: "<a href='/'>Go to home page</a>" ) if store.blocks.find_by_identity('unsubscription').blank?

      end
      Amz::Locale.all.each do |locale|
        # locale.mailer_templates.create(
        #   identity: 'welcome_email',
        #   subject: "Welcome {{email}}",
        #   body: '
        #   <p>Welcome {{email}}!</p>

        #   <p>You can go to your account through the link below:</p>
          
        #   <p><a href="{{account_url}}">My account</a></p>
        #   ' 
        # )  if locale.mailer_templates.find_by_identity('welcome_email').blank?
        locale.mailer_templates.create(
          identity: 'subscription_instructions',
          subject: "Thanks for your subscription",
          body: ' 
          <p>You can unsubscribe via the link below:</p> 
          
          <p>{{unsubscribion_url}}</p>
          
          ' 
        ) if locale.mailer_templates.find_by_identity('subscription_instructions').blank?
        locale.mailer_templates.create(
          identity: 'confirmation_instructions',
          subject: "Confirm your account email",
          body: '
          <p>Welcome {{email}}!</p>

          <p>&nbsp;</p>
          
          <p>You can confirm your account email through the url below:</p>
          
          <p>&nbsp;</p>
          
          <p>{{confirmation_url}}</p>
          
          ' 
        ) if locale.mailer_templates.find_by_identity('confirmation_instructions').blank?
        locale.mailer_templates.create(
          identity: 'reset_password',
          subject: "Reset Your Password",
          body: '
          <p>A request to reset your password has been made.</p>

          <p>If you did not make this request, simply ignore this email.</p>

          <p>If you did make this request just click the link below:</p>

          <p>&nbsp;</p>

          <p>{{edit_password_reset_url}}</p>

          <p>&nbsp;</p>

          <p>If the above URL does not work try copying and pasting it into your browser.</p>

          <p>If you continue to have problems please feel free to contact us.</p>

          <p>Email:{{store_email}}</p> 
          ' 
        ) if locale.mailer_templates.find_by_identity('reset_password').blank?
      end
  end  
end

 

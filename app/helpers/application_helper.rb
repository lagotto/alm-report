module ApplicationHelper
  @@template = %w{plos default}[1]

  def logo
    src = case @@template
    when 'plos'
      'logo.plos-alm.png'
    when 'default'
      (image_tag 'logo.alm.svg',
        alt: 'Public Library of Science', height: '48px') +
      (content_tag(:strong, 'ALM')+ " Reports")
    end

  end

  def footer_logo
    src = case @@template
    when 'plos'
      'footer.logo.plos-alm.png'
    when 'default'
      'footer.logo.alm.png'
    end
    image_tag src, :alt => 'Public Library of Science'
  end

  def font
    case @@template
    when 'plos'
      javascript_tag <<-SCRIPT
        WebFontConfig = { fontdeck: { id: '24557' } };

        (function() {
          var wf = document.createElement('script');
          wf.src = ('https:' == document.location.protocol ? 'https' : 'http') +
          '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
          wf.type = 'text/javascript';
          wf.async = 'true';
          var s = document.getElementsByTagName('script')[0];
          s.parentNode.insertBefore(wf, s);
        })();
      SCRIPT
    when 'default'
      stylesheet_link_tag 'http://fonts.googleapis.com/css?family=Fira+Sans:300,500,300italic,500italic'
    end
  end
end

$(function () {
  $('.facets .see_all a').click(function (e) {
    e.preventDefault();
    $(this).parent().parent().find('.additional').toggle();
    if($(this).text() == 'See top') {
      $(this).text('See all')
    } else {
      $(this).text('See top')
    }
  })

  $('.facets input[name=remove_facet]').change(function (e) {
    window.location = $(this).parent().find('a').attr('href');
  })
})



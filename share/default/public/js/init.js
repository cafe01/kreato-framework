$(function() {

    // pjax + nprogress
    NProgress.configure({
        showSpinner: false,
        minimum: 0.3,
        trickleRate: 0.1
    });
    $(document).on('page:fetch',   function() { NProgress.start(); });
    $(document).on('page:change',  function() { NProgress.done(); });
    $(document).on('page:restore', function() { NProgress.remove(); })
    $(document).on('turbolinks:load', initComponents)

}); // end of document ready


function initComponents() {

    // fix landing home height
    var landingHome = $('#landing-home');

    if (landingHome.size()) {

        var vPadding = landingHome.outerHeight() - landingHome.height()
            perfectHeight = $(window).height() - $('.nav-wrapper').height() - vPadding;

        if (perfectHeight > landingHome.height()) {
            landingHome.height(perfectHeight);
        }
    }


    //Init Button Collapse for Mobile
    $('.button-collapse').sideNav();

    //Init Testimonials Responsive Slides
    // $('.rslides').responsiveSlides({
    //     speed: 1000,
    //     timeout: 6500
    // });

    //Init Dropdown Menu
    $('.dropdown-button').dropdown();

    //Table of Contents
    $('.scrollspy').scrollSpy();
}

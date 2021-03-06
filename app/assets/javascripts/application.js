// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require_tree .

$(document).ready(function() {
    var assignUserModelUtils = (function() {
        return {
            setHref: function(path) {
                $('#assignToUserModal .btn-submit-user-to-assign').attr('href', path);
            },
            setItemName: function(name) {
                $('#assignToUserModal #assignItemName').text(name);
            },
            getSelectedUserId: function() {
                return $('#assignToUserModal select').val();
            }
        };
    })();

    $('.btn-assign-to-user').click(function() {
        var link = $(this);
        assignUserModelUtils.setHref(link.attr('data-item-url'));
        assignUserModelUtils.setItemName(link.attr('data-item-name'));
        $('.btn-submit-user-to-assign').off().click(function() {
            (function(anchor) {
                $.ajax(
                    {
                        type: 'POST',
                        url: anchor.href,
                        data: {user_id: assignUserModelUtils.getSelectedUserId()},
                        dataType: 'json'
                    }
                ).done(function(msg) {
                    if(msg && msg.state) {
                        if(msg.state === 'error') {
                            alert(msg.messages);
                        } else {
                            location.reload();
                        }
                    }
                });
            })(this);
           return false;
        });
    });

    $('.point-indicator').click(function() {
        $('.point-indicator').each(function(idx, element) {
            $(element).removeClass('point-indicator-selected');
        });
        $(this).addClass('point-indicator-selected');
    });

    $('.show-detail-estimations').off().click(function() {
        var link = this;
        var div = $(link).next();
        if(div.is(':visible')) {
            $(link).html('Show details');
            div.hide();
        } else {
            $.ajax( { url: link.href })
                .done(function(msg) {
                    div.html(msg);
                });
            $(link).html('Hide details');
            div.show();
        }
        return false;
    });
});
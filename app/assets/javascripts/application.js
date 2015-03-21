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
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require_tree .

$(document).ready(function() {
    var assignUserModelUtils = (function() {
        return {
            setAction: function(path) {
                $('#assignToUserModal form').attr('action', path);
            },
            setItemName: function(name) {
                $('#assignToUserModal #assignItemName').text(name);
            }
        };
    })();

    $('.btn-assign-to-user').click(function() {
        var link = $(this);
        assignUserModelUtils.setAction(link.attr('data-item-url'));
        assignUserModelUtils.setItemName(link.attr('data-item-name'));
    });
});
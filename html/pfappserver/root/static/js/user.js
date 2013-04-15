"use strict";

/*
 * The Users class defines the operations available from the controller.
 */
var Users = function() {
};

Users.prototype.get = function(options) {
    $.ajax({
        url: options.url
    })
        .always(options.always)
        .done(options.success)
        .fail(function(jqXHR) {
            var status_msg = getStatusMsg(jqXHR);
            showError(options.errorSibling, status_msg);
        });
};

Users.prototype.post = function(options) {
    $.ajax({
        url: options.url,
        type: 'POST',
        data: options.data
    })
        .done(options.success)
        .fail(function(jqXHR) {
            var status_msg = getStatusMsg(jqXHR);
            showError(options.errorSibling, status_msg);
        });
};

/*
 * The UserView class defines the DOM operations from the Web interface.
 */
var UserView = function(options) {
    this.users = options.users;

    var read = $.proxy(this.readUser, this);
    options.parent.on('click', '[href$="/read"]', read);

    var update = $.proxy(this.updateUser, this);
    $('body').on('submit', '#modalUser form[name="modalUser"]', update);

    var delete_user = $.proxy(this.deleteUser, this);
    $('body').on('click', '#modalUser [href$="/delete"]', delete_user);

    var reset_password = $.proxy(this.resetPassword, this);
    $('body').on('click', '#modalUser #resetPassword', reset_password);

    var mail_password = $.proxy(this.mailPassword, this);
    $('body').on('click', '#modalUser #mailPassword', mail_password);

    var read_node = $.proxy(this.readNode, this);
    $('body').on('click', '#modalUser [href$="/read"]', read_node);

    $('body').on('change', '#modalUser #ruleActions select[name$=type]', function(event) {
        /* Update the rule action fields when changing an action type */
        updateAction($(this));
    });

    $('body').on('admin.added', '#modalUser tr', function(event) {
        /* Update the rule action fields when adding an action */
        var tr = $(this);
        tr.find(':input').removeAttr('disabled');
        var type = tr.find('select[name$=type]').first();
        updateAction(type);
    });
};

UserView.prototype.readUser = function(e) {
    e.preventDefault();

    var modal = $('#modalUser');
    var section = $('#section');
    var loader = section.prev('.loader');
    loader.show();
    section.fadeTo('fast', 0.5);
    modal.empty();
    this.users.get({
        url: $(e.target).attr('href'),
        always: function() {
            loader.hide();
            section.stop();
            section.fadeTo('fast', 1.0);
        },
        success: function(data) {
            modal.append(data);
            modal.modal({ shown: true });
            modal.find('.datepicker').datepicker({ autoclose: true });
            modal.find('#ruleActions tr:not(.hidden) select[name$=type]').each(function() {
                updateAction($(this),true);
            });
            modal.on('shown', function() {
                modal.find(':input:visible').first().focus();
            });
        },
        errorSibling: section.find('h2').first()
    });
};

UserView.prototype.updateUser = function(e) {
    e.preventDefault();

    var modal = $('#modalUser');
    var form = modal.find('form').first();
    var valid = isFormValid(form);
    if (valid) {
        var modal_body = modal.find('.modal-body').first();
        resetAlert(modal_body);

        this.users.post({
            url: form.attr('action'),
            data: form.serialize(),
            success: function(data) {
                modal.modal('hide');
                modal.on('hidden', function() {
                    $(window).hashchange();
                });
            },
            errorSibling: modal_body.children().first()
        });
    }
};

UserView.prototype.deleteUser = function(e) {
    e.preventDefault();

    var btn = $(e.target);
    var url = btn.attr('href');
    this.users.get({
        url: url,
        success: function(data) {
            modal.modal('hide');
            modal.on('hidden', function() {
                $(window).hashchange();
            });
        },
        errorSibling: $('#section h2')
    });
};

UserView.prototype.resetPassword = function(e) {
    e.preventDefault();

    var btn = $(e.target);
    var url = btn.attr('href');
    var password = $('#password');
    var password_control = password.closest('.control-group');
    var password2 = $('#password2');
    var password2_control = password2.closest('.control-group');
    var sibbling = $('#userPassword').children().first();
    var valid = true;

    if (isFormInputEmpty(password) || isFormInputEmpty(password2))
        valid = false;
    else {
        if (password.val() != password2.val()) {
            password_control.addClass('error');
            password2_control.addClass('error');
            valid = false;
        }
        else {
            password_control.removeClass('error');
            password2_control.removeClass('error');
        }
    }
    if (valid) {
        this.users.post({
            url: url,
            data: { password: password.val() },
            success: function(data) {
                showSuccess(password_control, data.status_msg);
            },
            errorSibling: password_control
        });
    }
};

UserView.prototype.mailPassword = function(e) {
    e.preventDefault();

    var btn = $(e.target);
    var url = btn.attr('href');
    var control = $('#userPassword .control-group').first();
    this.users.get({
        url: url,
        success: function(data) {
            showSuccess(control, data.status_msg);
        },
        errorSibling: control
    });
};

UserView.prototype.up
    $('#modalUser').on('change', '#ruleActions select[name$=type]', function(event) {
        updateAction($(this));
    });


UserView.prototype.readNode = function(e) {
    e.preventDefault();

    var url = $(e.target).attr('href');
    var section = $('#section');
    var loader = section.prev('.loader');
    loader.show();
    section.fadeTo('fast', 0.5);
    this.users.get({
        url: url,
        always: function() {
            loader.hide();
            section.stop();
            section.fadeTo('fast', 1.0);
        },
        success: function(data) {
            $('body').append(data);
            var modalNode = $("#modalNode");
            var modalUser = $("#modalUser");
            modalUser.one('hidden',function(event){
                modalNode.modal('show');
            });
            modalNode.one('shown', function(event) {
                var modal = $(this);
                modal.find('.chzn-select').chosen();
                modal.find('.chzn-deselect').chosen({allow_single_deselect: true});
                modal.find('.timepicker-default').each(function() {
                    // Keep the placeholder visible if the input has no value
                    var that = $(this);
                    var defaultTime = that.val().length? 'value' : false;
                    that.timepicker({ defaultTime: defaultTime, showSeconds: false, showMeridian: false });
                    that.on('hidden',function (e){
                        //Stop the hidden event bubbling up to the modal
                        e.stopPropagation();
                    });
                });
                modal.find('.datepicker').datepicker({ autoclose: true });
                modal.find('a[href="#nodeHistory"]').on('shown', function () {
                    if ($('#nodeHistory .chart').children().length == 0)
                        drawGraphs();
                });
            });
            modalNode.one('hidden', function (eventObject) {
                $(this).remove();
                modalUser.modal('show');
            });

            modalUser.modal('hide');
        },
        errorSibling: section.find('h2').first()
    });
};
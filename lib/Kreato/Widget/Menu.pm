package Kreato::Widget::Menu;

use Mojo::Base -base;

has 'active_class' => sub { 'active' };
has 'selector' => sub { '.menu-item' };


sub register {
    my ($self, $plift) = @_;

    $plift->add_handler({
        name => 'widget-menu',
        tag => 'x-menu',
        handler => sub {
            $self->process(@_);
        }
    })
}

sub process {
    my ($self, $element, $c) = @_;

    # empty element
    # $self->_load_element_template($element)
    #    if $element->children->size == 0;

    my $item_tpl = $element->find($element->attr('selector') || $self->selector);

    # no template
    return unless $item_tpl->size;

    # static menu
    if ($item_tpl->size > 1) {

        $item_tpl->remove_class($self->active_class)->find('a')->remove_class($self->active_class);

        my $current_path = $c->helper->req->url->path;
        $c->app->log->debug('Path: '.$current_path);

        $item_tpl->find("a[href='".$current_path."']")
                 ->parent
                 ->add_class($self->active_class);

        $element->replace_with($element->contents);
        return;
    }

    # TODO user defined menu $c->menu($name)
    
    # TODO sitemap defined menu $c->website->sitemap
}

1;

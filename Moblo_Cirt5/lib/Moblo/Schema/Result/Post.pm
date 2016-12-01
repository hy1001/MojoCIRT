package Moblo::Schema::Result::Post;
use base qw/DBIx::Class::Core/;

# Associated table in database
__PACKAGE__->table('posts');

# Column definition
__PACKAGE__->add_columns(

    id => {
        data_type => 'integer',
        is_auto_increment => 1,
    },

    author_id => {
        data_type => 'integer',
    },

    title => {
        data_type => 'text',
    },

    content => {
        data_type => 'text',
    },

    date_published => {
        data_type => 'datetime',
    },

);

# Tell DBIC that 'id' is the primary key
__PACKAGE__->set_primary_key('id');


__PACKAGE__->belongs_to(
    # Name of the accessor for this relation
    author =>
    # Foreign result class
    'Moblo::Schema::Result::User',
    # Foreign key in THIS table
    'author_id'
);

__PACKAGE__->has_many(
    comments =>
    'Moblo::Schema::Result::Comment',
    'post_id'
);

1;
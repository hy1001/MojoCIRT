use Mojolicious::Lite;
use 5.22.0;

get '/' => {text => 'I ♥ Mojolicious!'};

app->start;

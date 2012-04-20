package MT::Plugin::OMV::Search::SearchStringNormalizer;
# $Id$

use strict;
use MT::App::Search;

use vars qw( $MYNAME $VERSION );
$MYNAME = (split /::/, __PACKAGE__)[-1];
(my $revision = '$Rev$') =~ s/\D//g;
$VERSION = "0.01_$revision";

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
    id => $MYNAME,
    key => $MYNAME,
    name => $MYNAME,
    version => $VERSION,
    author_name => 'Open MagicVox.net',
    author_link => 'http://www.magicvox.net/',
    plugin_link => 'http://www.magicvox.net/archive/2012/04201308/', # blog
    doc_link => 'http://lab.magicvox.net/trac/mt-plugins/wiki/SearchStringNormalizer',# trac
    description => <<'HTMLHEREDOC',
<__trans phrase="Convert the full-width alpha-numeric characters to the half-width ones in the search query.">
HTMLHEREDOC
});
MT->add_plugin( $plugin );



MT::App::Search->add_callback ('prepare_throttle', 9, $plugin, \&_hdlr_prepare_throttle);
sub _hdlr_prepare_throttle {
    my ($cb, $app) = @_;

    defined $app->param('normalize') && $app->param('normalize') == 0
        and return 1;
    my $search_string = $app->param('searchTerms') || $app->param('search')
        or return 1;

    # 全角空白＋全角英数字 → 半角
    my $fullwidthchars = Encode::decode ('utf8',
        '　！”＃＄％＆’（）＊＋，－．／'.
        '０１２３４５６７８９：；＜＝＞？'.
        '＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯ'.
        'ＰＱＲＳＴＵＶＷＸＹＺ［￥］＾＿'.
        '｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏ'.
        'ｐｑｒｓｔｕｖｗｘｙｚ｛｜｝～');
    # tr は変数を受けとれないので eval
    eval "\$search_string =~ tr/$fullwidthchars/ -~/";
    $search_string =~ s!^\s+|\s+$!!g;
    $search_string =~ s!\s+! !g;

    # 検索クエリを上書き
    $app->param('search', $search_string);
    $app->param('searchTerms', undef);
    return 1;
}

1;
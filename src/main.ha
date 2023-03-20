inc => unistd.h, thread
get => ncurses, ngui
get => Window

glob =>
    TCOLOR 4
    OCOLOR 5
    LCOLOR 6
    JCOLOR 10
    SCOLOR 11
    ZCOLOR 12
    ICOLOR 13
;

fn run Window *w, Ncurses *n =>
    loop
        w->draw()
        w->handle_key()
        usleep(1000)
    ;
;

fn main =>
    let n = Ncurses()
    init_pair(ICOLOR, COLOR_BLACK, COLOR_WHITE)
    n.start(true)
    let w = Window(&n)
    thread t(run, &w, &n)
    loop
        usleep(1000000)
        w.drop()
    ;
    t.join()
    n.stop()
;
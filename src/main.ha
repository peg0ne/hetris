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
    PCOLOR 14
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
    init_pair(PCOLOR, COLOR_BLACK, 240)
    srand(time(NULL))
    n.start(true)
    let w = Window(&n)
    thread t(run, &w, &n)
    loop
        usleep(max(1000000 - (100000 * w.get_level()), 50000))
        w.drop()
    ;
    t.join()
    n.stop()
;
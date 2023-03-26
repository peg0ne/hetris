get => dictionary
get => IBlock, TetrisHelpers

class Window => HorizontalLayout
    IContainer tetris_main = IContainer(Fill::Static, Vector(30,0))
    IContainer tetris_side = VerticalLayout(Fill::Static, Vector(20,0))
    IContainer tetris_score = IContainer(Fill::Static, Vector(0, 7))
    IContainer tetris_next = IContainer(Fill::Static, Vector(0, 4))
    IContainer tetris_level = IContainer(Fill::Static, Vector(0, 2))
    IContainer popup = IContainer(Vector(30, 6), Vector(COLS / 2 - 15, LINES / 2 - 3))
    Ncurses *n

    vector<IBlock> blocks = {}
    IBlock *current
    IBlock next = random_block()
    int level = 0
    int cleared_lines = 0
    int score = 0
    int top_score = 0
    bool pause = false
    bool stop = false
    bool is_game_over = false
    Window Ncurses *n =>
        this->n = n
        this->_offset = Vector(10,4)

        tetris_main.ToggleOutline()
        tetris_score.ToggleOutline()
        tetris_next.ToggleOutline()
        tetris_level.ToggleOutline()
        popup.SetActive(false)

        tetris_score.SetContent(List<string>({
            "Top",
            $"{top_score}",
            "",
            "Score",
            $"{score}",
            "Lines",
            $"{cleared_lines}"
        }))
        tetris_level.SetContent(List<string>({
            "Level",
            $"{level}"
        }))
        tetris_next.SetContent(List<string>({"NEXT"}))

        blocks.push_back(random_block())
        current = &blocks[0]

        add(new IContainer(Fill::Flex))
        add(&tetris_main)
        add(new IContainer(Fill::Static, Vector(3, 0)))
        add(&tetris_side)
        tetris_side.add(&tetris_score)
        tetris_side.add(new IContainer(Fill::Static, Vector(0, 2)))
        tetris_side.add(&tetris_next)
        tetris_side.add(new IContainer(Fill::Static, Vector(0, 2)))
        tetris_side.add(&tetris_level)
        add(new IContainer(Fill::Flex))
    ;
pub
    fn get_level => int doremi level
    fn update =>
        _size = Vector(COLS - (_offset.x * 2), LINES - (_offset.y * 2))
        ((HorizontalLayout*)this)->update()
    ;
    fn check_clear =>
        stop = true
        let size = tetris_main.Size()
        let lines = as_dict_line(blocks, size.x / 2)
        let cleared = clear_lines(lines, blocks, size.x / 2)
        cleared_lines += cleared.cleared
        blocks = cleared.blocks
        score += get_score(cleared.cleared, level)
        if is_level_up(cleared_lines, level) do level++
        stop = false
    ;
    fn check_collision Vector pos, bool is_down => bool
        let size = tetris_main.Size()
        let offset = tetris_main.Offset()
        let origin = Vector(offset.x + pos.x, offset.y + pos.y)
        let out_of_bounds_set = check_out_of_bounds(size, offset, pos, current)
        if out_of_bounds_set.b
            blocks.push_back(next)
            next = random_block()
            check_clear()
            current = &blocks[blocks.size() - 1]
        ;
        if out_of_bounds_set.a doremi true
        let hit_individual = check_individual_collisions(blocks, offset, pos, current, is_down)
        if hit_individual.b
            let content = List<string>({
                "          Game Over!",
                "",
                $"  Score: {score}",
            })
            if score > top_score 
                content.add("  NEW HIGHSCORE!!!")
                top_score = score
                score = 0
                cleared_lines = 0
                level = 0
            ;
            content.add("")
            content.add("  Press 'Enter' to continue:")
            popup.SetContent(content)
            popup.SetActive(true)
            popup.ToggleOutline()
            pause = true
            is_game_over = true
        ;
        if hit_individual.c
            blocks.push_back(next)
            next = random_block()
            check_clear()
            current = &blocks[blocks.size() - 1]
        ;
        return hit_individual.a
    ;
    fn drop =>
        if pause || stop do return
        try_move(Vector(0,1))
    ;
    fn try_move Vector dir => bool
        if pause || stop do return false
        stop = true
        let pos = current->pos
        pos.x += dir.x
        pos.y += dir.y
        if !check_collision(pos, dir.y > 0)
            current->pos = pos
            stop = false
            return true
        ;
        stop = false
        return false
    ;
    fn rotate =>
        if pause || stop do return
        let old_blocks = current->internal_blocks
        current->rotate()
        if check_collision(current->pos, false)
            current->internal_blocks = old_blocks
        ;
    ;
    fn handle_key =>
        let key = n->key()
        if key == -1 do return
        switch key
        case KEY_LEFT dobr try_move(Vector(-2, 0))
        case KEY_RIGHT dobr try_move(Vector(2, 0))
        case KEY_DOWN dobr try_move(Vector(0, 1))
        case KEY_UP dobr rotate()
        case '\n'
            pause = !pause
            popup.ToggleOutline()
            popup.SetActive(pause)
            if is_game_over
                is_game_over = false
                blocks.clear()
                next = random_block()
                blocks.push_back(next)
                next = random_block()
                current = &blocks[blocks.size() - 1]
            ;
            else
                popup.SetContent(List<string>({
                    "            Paused",
                    " ",
                    "  Press 'Enter' to continue:"
                }))
            ;
            break
        case ' '
            while try_move(Vector(0, 1)) do continue
            break
        case 'q'
            n->stop()
            exit(0)
            break
        ;
    ;
    fn draw =>
        n->clearScr()
        tetris_score.SetContent(List<string>({
            "Top",
            $"{top_score}",
            "",
            "Score",
            $"{score}",
            "Lines",
            $"{cleared_lines}"
        }))
        tetris_level.SetContent(List<string>({
            "Level",
            $"{level}"
        }))
        update()
        ((IContainer*)this)->draw(n)
        foreach c in _containers do draw_container_impl(c,n)
        tetris_main.draw_outline(n)
        tetris_score.draw_outline(n)
        tetris_next.draw_outline(n)
        tetris_level.draw_outline(n)
        let offset = tetris_main.Offset()
        let size = tetris_main.Size()
        foreach i,block in blocks
            let is_current = i == blocks.size() - 1
            let origin = Vector(offset.x + block.pos.x, offset.y + block.pos.y)
            n->col(block.color)
            foreach internal in block.internal_blocks
                let y = origin.y + internal.y
                let x = origin.x + internal.x
                if is_current && x >= offset.x
                    n->col(PCOLOR)
                    let p_pos = find_projection(blocks, current, offset, size)
                    n->add(p_pos - 1 + internal.y, origin.x + (internal.x * 2) - 1, "  ")
                    n->col(PCOLOR,false)
                    n->col(block.color)
                ;
                if x < offset.x || y < offset.y do continue
                n->add(origin.y + internal.y, origin.x + (internal.x * 2) - 1, "  ")
            ;
            n->col(block.color, false)
        ;
        offset = tetris_next.Offset()
        size = tetris_next.Size()
        n->col(next.color)
        foreach internal in next.internal_blocks
            n->add(offset.y + (size.y / 2) + internal.y, offset.x + (size.x / 2) + (internal.x * 2) - 1, "  ")
        ;
        n->col(next.color, false)
        popup.SetOffset(COLS / 2 - 15, LINES / 2 - 3)
        popup.draw(n)
        popup.draw_outline(n)
    ;
;
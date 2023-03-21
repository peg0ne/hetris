inc => bits/stdc++.h
get => dictionary
get => IBlock

class Window => HorizontalLayout
    IContainer tetris_main = IContainer(Fill::Static, Vector(30,0))
    IContainer tetris_side = VerticalLayout(Fill::Static, Vector(20,0))
    IContainer tetris_score = IContainer(Fill::Static, Vector(0, 7))
    IContainer tetris_next = IContainer(Fill::Static, Vector(0, 4))
    IContainer tetris_level = IContainer(Fill::Static, Vector(0, 2))
    Ncurses *n

    vector<IBlock> blocks = {}
    IBlock *current
    IBlock next = random_block()
    int level = 0
    int cleared_lines = 0
    int score = 0
    int top_score = 0
    Window Ncurses *n =>
        this->n = n
        this->_offset = Vector(10,4)

        tetris_main.ToggleOutline()
        tetris_score.ToggleOutline()
        tetris_next.ToggleOutline()
        tetris_level.ToggleOutline()

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
        let offset = tetris_main.Offset()
        let size = tetris_main.Size()
        Dictionary<int, int> lines = Dictionary<int, int>()
        foreach block in blocks
            foreach internal in block.internal_blocks
                select val from lines.try_get_value(block.pos.y + internal.y)
                    lines.set(block.pos.y + internal.y, val+1)
                    continue
                ;
                lines.add(block.pos.y + internal.y, 1)
            ;
        ;
        vector<IBlock> kept_blocks = {}
        int cleared = 0
        let keys = lines.keys()
        sort(keys.begin(), keys.end())
        foreach key in lines.keys()
            select val from lines.try_get_value(key)
                if val == size.x / 2
                    for i until blocks.size()
                        if i == blocks.size() - 1 dobr kept_blocks.push_back(blocks[i])
                        if blocks[i].pop(key - blocks[i].pos.y) do continue
                        kept_blocks.push_back(blocks[i])
                    ;
                    cleared++
                    blocks = kept_blocks
                    for i until blocks.size() do blocks[i].move_down(key - blocks[i].pos.y)
                    kept_blocks = {}
                ;
            ;
        ;
        cleared_lines += cleared
        if cleared_lines == (level + 1) * 5 do level++
        switch cleared
        case 1 dobr score += 40 * (level + 1)
        case 2 dobr score += 100 * (level + 1)
        case 3 dobr score += 300 * (level + 1)
        case 4 dobr score += 1200 * (level + 1)
        default do break
        ;
    ;
    fn check_collision Vector pos, bool is_down => bool
        let offset = tetris_main.Offset()
        let size = tetris_main.Size()
        let origin = Vector(offset.x + pos.x, offset.y + pos.y)
        foreach internal in current->internal_blocks
            let y = origin.y + internal.y
            let x = origin.x + (internal.x * 2) - 1
            if x < offset.x doremi true
            if x >= offset.x + size.x doremi true
            if y >= offset.y + size.y
                blocks.push_back(next)
                next = random_block()
                check_clear()
                current = &blocks[blocks.size() - 1]
                return true
            ;
        ;
        foreach i,block in blocks
            if i == blocks.size() - 1 do break
            let i_origin = Vector(offset.x + block.pos.x, offset.y + block.pos.y)
            foreach internal_block in block.internal_blocks
                let i_y = i_origin.y + internal_block.y
                let i_x = i_origin.x + (internal_block.x * 2) - 1
                foreach current_internal in current->internal_blocks
                    let c_y = origin.y + current_internal.y
                    let c_x = origin.x + (current_internal.x * 2) -1
                    if i_y == c_y && i_x == c_x
                        if is_down
                            blocks.push_back(next)
                            next = random_block()
                            check_clear()
                            current = &blocks[blocks.size() - 1]
                        ;
                        return true
                    ;
                ;
            ;
        ;
        return false
    ;
    fn drop => do try_move(Vector(0,1))
    fn try_move Vector dir => bool
        let pos = current->pos
        pos.x += dir.x
        pos.y += dir.y
        if !check_collision(pos, dir.y > 0)
            current->pos = pos
            return true
        ;
        return false
    ;
    fn rotate =>
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
        foreach block in blocks
            let offset = tetris_main.Offset()
            let origin = Vector(offset.x + block.pos.x, offset.y + block.pos.y)
            n->col(block.color)
            foreach internal in block.internal_blocks
                let y = origin.y + internal.y
                let x = origin.x + internal.x
                if x < offset.x || y < offset.y do continue
                n->add(origin.y + internal.y, origin.x + (internal.x * 2) - 1, "  ")
            ;
            n->col(block.color, false)
        ;
        let offset = tetris_next.Offset()
        let size = tetris_next.Size()
        n->col(next.color)
        foreach internal in next.internal_blocks
            n->add(offset.y + (size.y / 2) + internal.y, offset.x + (size.x / 2) + (internal.x * 2) - 1, "  ")
        ;
        n->col(next.color, false)
    ;
;
fn as_dict_line vector<IBlock> blocks, int max_count => Dictionary<int, int>
    Dictionary<int, int> lines = Dictionary<int, int>()
    foreach block in blocks
        foreach internal_block in block.internal_blocks
            select val from lines.try_get_value(block.pos.y + internal_block.y)
                lines.set(block.pos.y + internal_block.y, val + 1)
                continue
            ;
            lines.add(block.pos.y + internal_block.y, 1)
        ;
    ;
    return lines
;

struct Cleared
    int cleared
    vector<IBlock> blocks
    Cleared int cleared, vector<IBlock> blocks =>
        this->cleared = cleared
        this->blocks = blocks
    ;
;
fn remove_blocks IBlock block, int pos => Option<IBlock>
    if block.pop(pos) doremi None<IBlock>()
    return Some(block)
;
fn clear_lines Dictionary<int, int> lines, vector<IBlock> blocks, int max_count => Cleared
    let keys = lines.keys()
    let cleared = 0
    sort(keys.begin(), keys.end())
    vector<IBlock> kept_blocks = {}
    foreach key in keys
        if max_count != lines.try_get_value(key).value_or(0) do continue
        cleared++
        for i until blocks.size()
            if i == blocks.size() - 1 dobr kept_blocks.push_back(blocks[i])
            select b from remove_blocks(blocks[i], key - blocks[i].pos.y)
                kept_blocks.push_back(b)
            ;
        ;
        blocks = kept_blocks
        kept_blocks = {}
        for i until blocks.size()
            if i == blocks.size() - 1 do continue
            blocks[i].move_down(key - blocks[i].pos.y)
        ;
    ;
    return Cleared(cleared, blocks)
;

fn is_level_up int cleared, int level => bool doremi cleared >= (level + 1) * 10
fn get_score int cleared, int level => int
    switch cleared
    case 1 doremi 40 * (level + 1)
    case 2 doremi 100 * (level + 1)
    case 3 doremi 300 * (level + 1)
    case 4 doremi 1200 * (level + 1)
    default doremi 0
    ;
;

struct Set
    bool a
    bool b
    bool c
    Set => do return
    Set bool a, bool b =>
        this->a = a
        this->b = b
        this->c = false
    ;
    Set bool a, bool b, bool c =>
        this->a = a
        this->b = b
        this->c = c
    ;
;
fn check_out_of_bounds Vector size, Vector offset, Vector pos, IBlock *block => Set
    let origin = Vector(offset.x + pos.x, offset.y + pos.y)
    foreach internal in block->internal_blocks
        let y = origin.y + internal.y
        let x = origin.x + (internal.x * 2) - 1
        if x < offset.x doremi Set(true, false)
        if x >= offset.x + size.x doremi Set(true, false)
        if y >= offset.y + size.y doremi Set(true, true)
    ;
    return Set(false, false)
;

fn check_individual_collisions vector<IBlock> blocks, Vector offset, Vector pos, IBlock *current, bool is_down => Set
    let origin = Vector(offset.x + pos.x, offset.y + pos.y)
    foreach i, block in blocks
        if i == blocks.size() - 1 doremi Set(false, false, false)
        let other_origin = Vector(offset.x + block.pos.x, offset.y + block.pos.y)
        foreach internal_block in block.internal_blocks
            let other_vec = Vector(other_origin.x + (internal_block.x * 2) - 1, other_origin.y + internal_block.y)
            foreach current_internal in current->internal_blocks
                let vec = Vector(origin.x + (current_internal.x * 2) - 1, origin.y + current_internal.y)
                if !vec.eq(other_vec) do continue
                if !is_down doremi Set(true, false, false)
                foreach check_block in current->internal_blocks
                    if origin.y + check_block.y < offset.y doremi Set(true, true, true)
                ;
                return Set(true, false, true)
            ;
        ;
    ;
    return Set(false, false, false)
;
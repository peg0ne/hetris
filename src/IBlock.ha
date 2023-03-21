struct IBlock
    Vector pos = Vector(0,0)
    short color = 0
    vector<Vector> internal_blocks = {}
    bool can_rotate = true
    IBlock => do return
    IBlock Vector pos, short color, bool can_rotate, vector<Vector> internal_blocks =>
        this->pos = pos
        this->color = color
        this->can_rotate = can_rotate
        this->internal_blocks = internal_blocks
    ;
    fn rotate =>
        if !can_rotate do return
        let blocks = internal_blocks
        foreach i,block in blocks
            let x = block.x
            let y = block.y
            if 0 =&= x : y do continue
            if x == y doco blocks[i] = Vector(-x, y)
            if x == -y doco blocks[i] = Vector(x, -y)
            if x == 0 doco blocks[i] = Vector(-y, 0)
            if y == 0 doco blocks[i] = Vector(0, x)
        ;
        internal_blocks = blocks
    ;
    fn pop int y => bool
        vector<Vector> blocks = {}
        foreach block in internal_blocks do blocks.push_back(block)
        internal_blocks = {}
        foreach block in blocks
            if block.y == y do continue
            internal_blocks.push_back(block)
        ;
        return internal_blocks.size() == 0
    ;
    fn move_down int y =>
        foreach i,block in internal_blocks
            if block.y >= y do continue
            internal_blocks[i].y++
        ;
    ;
;

fn T_Block => IBlock doremi IBlock(Vector(13,0), TCOLOR, true,{
            Vector(0,0),
            Vector(1,0),
            Vector(-1,0),
            Vector(0,-1)
        })
fn O_Block => IBlock doremi IBlock(Vector(13,0), OCOLOR, false,{
            Vector(0,0),
            Vector(1,0),
            Vector(0,-1),
            Vector(1,-1)
        })
fn L_Block => IBlock doremi IBlock(Vector(13,0), LCOLOR, true,{
            Vector(0,0),
            Vector(1,0),
            Vector(0,-1),
            Vector(0,-2)
        })
fn J_Block => IBlock doremi IBlock(Vector(13,0), JCOLOR, true,{
            Vector(0,0),
            Vector(-1,0),
            Vector(0,-1),
            Vector(0,-2)
        })
fn S_Block => IBlock doremi IBlock(Vector(13,0), SCOLOR, true,{
            Vector(0,0),
            Vector(-1,0),
            Vector(0,-1),
            Vector(1,-1)
        })
fn Z_Block => IBlock doremi IBlock(Vector(13,0), ZCOLOR, true,{
            Vector(0,0),
            Vector(1,0),
            Vector(0,-1),
            Vector(-1,-1)
        })
fn I_Block => IBlock doremi IBlock(Vector(13,0), ICOLOR, true,{
            Vector(0,0),
            Vector(0,1),
            Vector(0,-1),
            Vector(0,-2)
        })

fn random_block => IBlock
    switch rand() % 7
    case 0 doremi T_Block()
    case 1 doremi O_Block()
    case 2 doremi L_Block()
    case 3 doremi J_Block()
    case 4 doremi S_Block()
    case 5 doremi Z_Block()
    case 6 doremi I_Block()
    default doremi T_Block()
    ;
;
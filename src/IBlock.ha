struct IBlock
    Vector pos = Vector(0,0)
    short color = 0
    vector<Vector> internal_blocks = {}
    IBlock => do return
    IBlock Vector pos, short color, vector<Vector> internal_blocks =>
        this->pos = pos
        this->color = color
        this->internal_blocks = internal_blocks
    ;
    fn rotate =>
        foreach i,block in internal_blocks
            let x = block.x
            let y = block.y
            if 0 =&= x : y do continue
            if x == y doco internal_blocks[i] = Vector(-x, y)
            if x == -y doco internal_blocks[i] = Vector(x, -y)
            if x == 0 doco internal_blocks[i] = Vector(-y, 0)
            if y == 0 doco internal_blocks[i] = Vector(0, x)
        ;
    ;
;

fn T_Block => IBlock doremi IBlock(Vector(13,0), TCOLOR, {
            Vector(0,0),
            Vector(1,0),
            Vector(-1,0),
            Vector(0,-1)
        })
fn O_Block => IBlock doremi IBlock(Vector(13,0), OCOLOR, {
            Vector(0,0),
            Vector(1,0),
            Vector(0,-1),
            Vector(1,-1)
        })
fn L_Block => IBlock doremi IBlock(Vector(13,0), LCOLOR, {
            Vector(0,0),
            Vector(1,0),
            Vector(0,-1),
            Vector(0,-2)
        })
fn J_Block => IBlock doremi IBlock(Vector(13,0), JCOLOR, {
            Vector(0,0),
            Vector(-1,0),
            Vector(0,-1),
            Vector(0,-2)
        })
fn S_Block => IBlock doremi IBlock(Vector(13,0), SCOLOR, {
            Vector(0,0),
            Vector(-1,0),
            Vector(0,-1),
            Vector(1,-1)
        })
fn Z_Block => IBlock doremi IBlock(Vector(13,0), ZCOLOR, {
            Vector(0,0),
            Vector(1,0),
            Vector(0,-1),
            Vector(-1,-1)
        })
fn I_Block => IBlock doremi IBlock(Vector(13,0), ICOLOR, {
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
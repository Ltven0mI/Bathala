local m = {}
m.width = 3
m.height = 3
m.depth = 3
m.tileIndex = {
    [1]="pillar_layer3",
    [2]="wall",
    [3]="ground_smooth",
    [4]="pillar_layer2",
    [5]="statue_base_topleft",
    [7]="pillar_layer1",
    [8]="statue_base_bottomleft",
    [9]="statue_base_bottomright",
    [11]="carpet_right",
    [12]="statue_base_topright",
    [13]="carpet_left",
    [14]="pillar_layer5",
    [15]="pillar_layer4",
    [16]="carpet_middle",
    [17]="pillar_layer5_front",
    [18]="ground_cracked",
}
m.tileIndexGrid = {
    [1] = {
        [1] = {
            [1] = 13,
            [2] = 13,
            [3] = 13
        },
        [2] = {
            [1] = 7,
            [2] = 0,
            [3] = 0
        },
        [3] = {
            [1] = 4,
            [2] = 0,
            [3] = 0
        }
    },
    [2] = {
        [1] = {
            [1] = 16,
            [2] = 16,
            [3] = 16
        },
        [2] = {
            [1] = 0,
            [2] = 0,
            [3] = 0
        },
        [3] = {
            [1] = 0,
            [2] = 0,
            [3] = 0
        }
    },
    [3] = {
        [1] = {
            [1] = 11,
            [2] = 11,
            [3] = 11
        },
        [2] = {
            [1] = 7,
            [2] = 0,
            [3] = 0
        },
        [3] = {
            [1] = 4,
            [2] = 0,
            [3] = 0
        }
    }
}
m.entities = {
}
return m
static HashMap < Integer, int[][] > getPositions() {
    HashMap < Integer, int[][] > positions = new HashMap < > ();
    positions.put(1, new int[][] {
        {
            0,
            0,
            0
        }
    });
    positions.put(2, new int[][] {
        {
            0,
            -400,
            0
        }, {
            0,
            450,
            180
        },
    });
    positions.put(3, new int[][] {
        {
            0,
            0,
            0
        }, {
            0,
            -450,
            0
        }, {
            0,
            450,
            180
        },
    });
    positions.put(4, new int[][] {
        {
            -200, -450, 0
        }, {
            200,
            -450,
            0
        }, {
            -200,
            450,
            180
        }, {
            200,
            450,
            180
        },
    });
    positions.put(5, new int[][] {
        {
            -200, -450, 0
        }, {
            200,
            -450,
            0
        }, {
            -200,
            450,
            180
        }, {
            200,
            450,
            180
        }, {
            0,
            0,
            0
        },
    });
    positions.put(6, new int[][] {
        {
            -200, -450, 0
        }, {
            200,
            -450,
            0
        }, {
            -200,
            450,
            180
        }, {
            200,
            450,
            180
        }, {
            -200,
            0,
            0
        }, {
            200,
            0,
            0
        },
    });
    positions.put(7, new int[][] {
        {
            -200, -450, 0
        }, {
            200,
            -450,
            0
        }, {
            -200,
            450,
            180
        }, {
            200,
            450,
            180
        }, {
            -200,
            0,
            0
        }, {
            200,
            0,
            0
        }, {
            0,
            -250,
            0
        },
    });
    positions.put(8, new int[][] {
        {
            -200, -450, 0
        }, {
            200,
            -450,
            0
        }, {
            -200,
            450,
            180
        }, {
            200,
            450,
            180
        }, {
            -200,
            0,
            0
        }, {
            200,
            0,
            0
        }, {
            0,
            -250,
            0
        }, {
            0,
            250,
            180
        },
    });
    positions.put(9, new int[][] {
        {
            200,
            -450,
            0
        }, {
            -200,
            -450,
            0
        }, {
            200,
            450,
            180
        }, {
            -200,
            450,
            180
        }, {
            -200,
            -150,
            0
        }, {
            200,
            -150,
            0
        }, {
            -200,
            150,
            180
        }, {
            200,
            150,
            180
        }, {
            0,
            0,
            0
        },
    });
    positions.put(10, new int[][] {
        {
            200,
            -450,
            0
        }, {
            -200,
            -450,
            0
        }, {
            200,
            450,
            180
        }, {
            -200,
            450,
            180
        }, {
            -200,
            -150,
            0
        }, {
            200,
            -150,
            0
        }, {
            -200,
            150,
            180
        }, {
            200,
            150,
            180
        }, {
            0,
            -250,
            0
        }, {
            0,
            250,
            180
        },
    });

    return positions;
}

static ArrayList < PVector > getHeart(int numPoints) {
    ArrayList < PVector > points = new ArrayList < > ();
    for (int angle = -180; angle < 180; angle += 360 / numPoints) {
        float radAng = radians(angle);
        points.add(
            new PVector(
                (float)(8 * Math.pow(sin(radAng), 3)),
                9 * cos(0.9 * radAng) -
                0.5 * cos(2 * radAng) -
                3.5 * cos(2.15 * radAng) -
                cos(3 * radAng)
            )
            .mult(10)
            .rotate(3.14)
        );
    }
    return points;
}

static ArrayList < PVector > getDiamond(int numPoints) {
    ArrayList < PVector > diamond = new ArrayList < PVector > ();
    // Bottom-left
    for (float x = 0; x > -50; x -= 50.5 / (numPoints / 4)) {
        diamond.add(new PVector(x, -2 * x - 100).rotate(3.14));
    }
    // Top-right
    for (float x = -50; x < 0; x += 50.5 / (numPoints / 4)) {
        diamond.add(new PVector(x, 2 * x + 100).rotate(3.14));
    }

    // Top-right side
    for (float x = 0; x < 50; x += 50.5 / (numPoints / 4)) {
        diamond.add(new PVector(x, -2 * x + 100).rotate(3.14));
    }

    // Bottom-right
    for (float x = 50; x >= 0; x -= 50.5 / (numPoints / 4)) {
        diamond.add(new PVector(x, 2 * x - 100).rotate(3.14));
    }
    return diamond;
}

static ArrayList < PVector > getSpade(int numPoints) {
    ArrayList < PVector > spade = new ArrayList < PVector > ();

    for (float x = 0; x > -30; x -= 30.0 / (numPoints * 0.08)) {
        PVector v = new PVector(x, -100).rotate(3.14);

        spade.add(v);
    }

    for (float x = -30; x < -10; x += 20.0 / (numPoints * 0.14)) {
        PVector v = new PVector(x, 3 * (x - 10.0 / 3)).rotate(3.14);
        spade.add(v);
    }
    for (
        float angle = -PI / 6; angle >= -PI; angle -= (PI * 5) / 6 / (numPoints * 0.27)
    ) {
        PVector v = new PVector(
                (float)(7.5 * Math.pow(sin(angle), 3)), -7 * cos(0.9 * angle) +
                0.1 * cos(3 * angle) +
                3 * cos(2.08 * angle) +
                cos(2.9 * angle) +
                1
            )
            .mult(10)
            .rotate(3.14);
        //console.log(angle, v)
        spade.add(v);
    }
    for (
        float angle = 3.14; angle > 3.14 / 6 + 0.01; angle -= (3.14 * 5) / 6 / (numPoints * 0.31)
    ) {
        spade.add(
            new PVector(
                (float)(7.5 * Math.pow(sin(angle), 3)), -7 * cos(0.9 * angle) +
                0.1 * cos(3 * angle) +
                3 * cos(2.08 * angle) +
                cos(2.9 * angle) +
                1
            )
            .mult(10)
            .rotate(3.14)
        );
    }
    for (float x = 10; x < 30; x += 20.0 / (numPoints * 0.08)) {
        spade.add(new PVector(x, -3 * (x + 10.0 / 3)).rotate(3.14));
    }

    for (float x = 30; x > 0; x -= 30.0 / (numPoints * 0.08)) {
        spade.add(new PVector(x, -100).rotate(3.14));
    }

    return spade;
}

static ArrayList < PVector > getClub(int numPoints) {
    ArrayList < PVector > club = new ArrayList < PVector > ();

    for (float x = 0; x > -30; x -= 30.0 / (numPoints * 0.03)) {
        club.add(new PVector(x, -100).rotate(3.14));
    }

    for (float x = -30; x < -10; x += 20.0 / (numPoints * 0.12)) {
        club.add(new PVector(x, 3 * (x - 10 / 3)).rotate(3.14));
    }
    for (
        float angle = (-3.14 * 4) / 3; angle <= 3.14 / 6; angle += (1.5 * 3.14) / (numPoints * 0.24)
    ) {
        club.add(
            new PVector(-4.5 + 4 * sin(angle), -2 + 4 * cos(angle))
            .mult(10)
            .rotate(3.14)
        );
    }

    for (
        float angle = (-3.14 * 4) / 5; angle <= (3.14 * 4) / 5; angle += (3.14 * 8) / 5 / (numPoints * 0.24)
    ) {
        club.add(
            new PVector(4 * sin(angle), 4.6 + 4 * cos(angle))
            .mult(10)
            .rotate(3.14)
        );
    }

    for (
        float angle = -3.14 / 6; angle <= (3.14 * 4) / 3 - 0.1; angle += (1.5 * 3.14) / (numPoints * 0.24)
    ) {
        club.add(
            new PVector(4.5 + 4 * sin(angle), -2 + 4 * cos(angle))
            .mult(10)
            .rotate(3.14)
        );
    }

    for (float x = 13; x < 30; x += 17.0 / (numPoints * 0.04)) {
        club.add(new PVector(x, -3 * (x + 10 / 3)).rotate(3.14));
    }

    for (float x = 30; x > 0; x -= 30.0 / (numPoints * 0.03)) {
        club.add(new PVector(x, -100).rotate(3.14));
    }

    return club;
}
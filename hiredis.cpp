/*
 
    install hiredis

*/

#include <hiredis/hiredis.h>
#include <iostream>

int main() {
    // Connect to Redis
    redisContext *c = redisConnect("127.0.0.1", 6379);
    if (c == nullptr || c->err) {
        std::cerr << "Connection error: " << (c ? c->errstr : "Can't allocate redis context") << std::endl;
        return 1;
    }

    // Add players to ZSET
    redisReply *reply = (redisReply *)redisCommand(c, "ZADD game:scores 100 Alice 200 Bob 150 Charlie");
    freeReplyObject(reply);

    // Get top 3 players
    reply = (redisReply *)redisCommand(c, "ZREVRANGE game:scores 0 2 WITHSCORES");
    if (reply->type == REDIS_REPLY_ARRAY) {
        for (size_t i = 0; i < reply->elements; i += 2) {
            std::cout << reply->element[i]->str << ": " << reply->element[i + 1]->str << std::endl;
        }
    }
    freeReplyObject(reply);

    // Clean up
    redisFree(c);
    return 0;
}
